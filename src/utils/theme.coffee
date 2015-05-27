riot = require 'riot'

$style = $('<style>')
$('head').append $style

theme =
  currentTheme: {}
  setTheme: (newTheme)->
    $.extend(theme.currentTheme, newTheme)

    $style.html """
      /* Colors */
      .crowdstart-checkout {
        background-color: #{ theme.currentTheme.background } !important;
      }

      .crowdstart-promocode-button {
        background-color: #{ theme.currentTheme.promoCodeBackground } !important;
        color: #{ theme.currentTheme.promoCodeForeground } !important;
      }

      .crowdstart-checkout-button {
        background-color: #{ theme.currentTheme.calloutBackground } !important;
        color: #{ theme.currentTheme.calloutForeground } !important;
      }

      .crowdstart-checkout {
        color: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-form-control input,
      .select2-container input {
        border: 1px solid #{ theme.currentTheme.medium } !important;
      }

      .select2, .select2 *, .select2-selection {
        color: #{ theme.currentTheme.dark } !important;
        border-color: #{ theme.currentTheme.medium } !important;
        background-color: transparent !important;
      }

      .select2-container--default
      .select2-selection--single
      .select2-selection__arrow b {
        border-color: #{ theme.currentTheme.dark } transparent transparent transparent !important;
      }

      .select2-container--default {
        background-color: transparent !important;
        border-color: #{ theme.currentTheme.medium } !important;
      }

      .select2-dropdown {
        background-color: #{ theme.currentTheme.background } !important;
        border-color: #{ theme.currentTheme.medium } !important;
      }

      .crowdstart-sep {
        border-bottom: 1px solid #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-thankyou a {
        color: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-thankyou a:visited {
        color: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-error input {
        border-color: #{ theme.currentTheme.error } !important;
      }

      .crowdstart-message::before {
        background-color: #{ theme.currentTheme.error } !important;
      }

      .crowdstart-message {
        color: #{ theme.currentTheme.light } !important;
        background-color: #{ theme.currentTheme.error } !important;
      }

      .crowdstart-show-promocode {
        color: #{ theme.currentTheme.showPromoCode } !important;
      }

      .crowdstart-loader {
        border-top: 1.1em solid #{ theme.currentTheme.spinnerTrail } !important;
        border-right: 1.1em solid #{ theme.currentTheme.spinnerTrail } !important;
        border-bottom: 1.1em solid #{ theme.currentTheme.spinnerTrail } !important;
        border-left: 1.1em solid #{ theme.currentTheme.spinner } !important;
      }

      .crowdstart-progress li {
        color: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-progress li:before {
        color: #{ theme.currentTheme.light } !important;
        background-color: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-progress li:after {
        background: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-progress li.active {
        color: #{ theme.currentTheme.progress } !important;
      }

      .crowdstart-progress li.active:before,  .crowdstart-progress li.active:after{
        background: #{ theme.currentTheme.progress } !important;
        color: #{ theme.currentTheme.light } !important;
      }

      .crowdstart-checkbox-control input[type="checkbox"] + label .crowdstart-checkbox {
        border: 1px solid #{ theme.currentTheme.medium } !important;
      }

      .crowdstart-checkbox-short-part {
        background-color: #{ theme.currentTheme.dark } !important;
      }

      .crowdstart-checkbox-long-part {
        background-color: #{ theme.currentTheme.dark } !important;
      }

      .select2-results__option--highlighted {
        color: #{ theme.currentTheme.light } !important !important;
      }
      /* End Colors */

      /* Border Radius */
      .crowdstart-checkout {
        border-radius: #{ theme.currentTheme.borderRadius }px !important;
      }

      .crowdstart-form-control input,
      .select2-container input {
        border-radius: #{ theme.currentTheme.borderRadius }px !important;
      }

      .crowdstart-promocode-button {
        border-radius: #{ theme.currentTheme.borderRadius }px !important;
      }

      .crowdstart-checkout-button {
        border-radius: #{ theme.currentTheme.borderRadius }px !important;
      }

      .crowdstart-progress li:before {
        border-radius: #{ if theme.currentTheme.borderRadius > 0 then 3 else 0 }px !important;
      }
      /* End Border Radius */

      /* Font Family */
      .crowdstart-checkout {
        font-family: #{ theme.currentTheme.fontFamily };
      }

      .select2 *, .select2-results *, .select2-container * {
        font-family: #{ theme.currentTheme.fontFamily };
      }
      /* End Font Family */
    """

theme.setTheme(
  background: 'white'
  light: 'white'
  dark: 'lightslategray'
  medium: '#DDDDDD'
  error: 'red'
  promoCodeForeground: 'white'
  promoCodeBackground: 'lightslategray'
  calloutForeground: 'white'
  calloutBackground: '#27AE60'
  showPromoCode: 'steelblue'
  progress: '#27AE60'
  spinner: 'rgb(255,255,255)'
  spinnerTrail: 'rgba(255,255,255,0.2)'
  fontFamily: "'Helvetica Neue', Helvetica, Arial, sans-serif"
  borderRadius: 5)

module.exports = theme
