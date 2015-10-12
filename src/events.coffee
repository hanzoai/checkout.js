crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events

Events.ProgressBar =
  Update: 'progressbar-update'

Events.Checkout =
  Update: 'checkout-update'

Events.Modal =
  Open:         'modal-open'
  Close:        'modal-close'
  DisableClose: 'modal-disable-close'
  EnableClose:  'modal-enable-close'


