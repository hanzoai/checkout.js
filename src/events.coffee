crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events

Events.Screen =
  TryNext:      'screen-try-next'
  Next:         'screen-next'
  Back:         'screen-back'
  UpdateScript: 'screen-update-script'

Events.Checkout =
  Update: 'checkout-update'

Events.Modal =
  Open:         'modal-open'
  Close:        'modal-close'
  DisableClose: 'modal-disable-close'
  EnableClose:  'modal-enable-close'

Events.Confirm =
  Hide:     'confirm-hide'
  Show:     'confirm-show'
  Lock:     'confirm-lock'
  Unlock:   'confirm-unlock'

Events.Invoice =
  Disabled: 'invoice-disable'
  Enable:   'invoice-enable'
