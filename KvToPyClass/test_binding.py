from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label


class MyWidget(BoxLayout):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        widget_6BA18268 = Label(text="app.some_prop", font_size=20.0)
        self.add_widget(widget_6BA18268)
        widget_D0745823 = Button(text="Click Me")
        widget_D0745823.bind(on_press=lambda instance: app.handle_click ())
        self.add_widget(widget_D0745823)