const cds = require('@sap/cds')

module.exports = class CatalogService extends cds.ApplicationService { init() {

  const { SalesOrders, SalesOrderItems, Products } = cds.entities('sap.capire.salesorders')
  const { ListOfOrders } = this.entities

  // Tag clearly oversized orders so the list UI can highlight them.
  this.after('each', ListOfOrders, order => {
    if (order.grossAmount && order.grossAmount > 100000) {
      order.note = (order.note ? order.note + ' ' : '') + '-- top deal'
    }
  })

  // Submit (confirm) a New order: move it to InProgress and decrement stock per item.
  this.on('submitOrder', async req => {
    const { orderID } = req.data
    const order = await SELECT.one.from(SalesOrders, orderID)
    if (!order) return req.error(404, `Order #${orderID} doesn't exist`)
    if (order.status !== 'New') {
      return req.error(409, `Order #${orderID} is already ${order.status}`)
    }

    const items = await SELECT.from(SalesOrderItems).where({ parent_ID: orderID })
    for (const item of items) {
      const product = await SELECT.one.from(Products, item.product_ID, p => p.stock)
      if (!product) return req.error(404, `Product #${item.product_ID} doesn't exist`)
      if (product.stock == null || product.stock < item.quantity) {
        return req.error(409, `Quantity ${item.quantity} exceeds stock for product #${item.product_ID}`)
      }
      await UPDATE(Products, item.product_ID).with({ stock: product.stock - item.quantity })
    }

    await UPDATE(SalesOrders, orderID).with({ status: 'InProgress' })
    return { status: 'InProgress' }
  })

  // Emit an event when an order has been submitted.
  this.after('submitOrder', async (_, req) => {
    const { orderID } = req.data
    await this.emit('OrderSubmitted', { orderID, buyer: req.user.id })
  })

  return super.init()
}}
