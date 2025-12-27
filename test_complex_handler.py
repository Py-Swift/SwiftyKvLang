from kivy.uix.button import Button


class ComplexButton(Button):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.text = "Test"
        self.bind(on_press=self._on_press_handler)
        self.bind(on_release=self._on_release_handler)

    def _on_press_handler(self, instance):
        app.on_button_press ()

    def _on_release_handler(self, instance):
        print ("Released!" )