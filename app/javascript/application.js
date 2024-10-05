// Dependencies
import { RalixApp } from 'ralix'
import "@hotwired/turbo-rails"
import "trix"
import "@rails/actiontext"
import { Application } from "stimulus"
import ConfirmationController from "./controllers/confirmation_controller"

// Controllers
import AppCtrl      from './controllers/app'
import ArticlesCtrl from './controllers/articles'

// Components
import RemoteModal  from './components/remote_modal'
import Tooltip      from './components/tooltip'
import 'flowbite';
import "flowbite/dist/flowbite.turbo.js";
import 'flowbite-datepicker';
import 'flowbite/dist/datepicker.turbo.js';

// Configurar Stimulus
const application = Application.start()
application.register("confirmation", ConfirmationController)

const App = new RalixApp({
  routes: {
    '/articles$': ArticlesCtrl,
    '/.*': AppCtrl
  },
  components: [
    RemoteModal,
    Tooltip
  ]
})

App.start()
