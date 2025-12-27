from kivy.uix.button import Button


class MyButton(Button):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.text = "Press me"
        self.bind(on_press=self._on_press_handler)

    def _on_press_handler(self, instance):
        print ("Button pressed!" )