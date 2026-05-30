const cds = require('@sap/cds')

module.exports = class AdminService extends cds.ApplicationService { init() {

  const { SalesOrders } = this.entities

  /**
   * Generate sequential IDs for new SalesOrders drafts.
   * Mirrors the previous Books ID auto-numbering: take the largest existing
   * ID across active and draft rows and bump by 1.
   */
  this.before ('NEW', SalesOrders.drafts, async (req) => {
    if (req.data.ID) return
    const { ID:id1 } = await SELECT.one.from(SalesOrders).columns('max(ID) as ID')
    const { ID:id2 } = await SELECT.one.from(SalesOrders.drafts).columns('max(ID) as ID')
    req.data.ID = Math.max(id1||0, id2||0) + 1
  })
  return super.init()
}}
