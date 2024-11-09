// app/javascript/controllers/confirmation_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
    static values = {
        message: String
    }

    confirm(event) {
        // Mostrar un mensaje de confirmación
        if (!confirm(this.messageValue)) {
            event.preventDefault(); // Evitar la acción si el usuario cancela
        }
    }
}