from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.switch import Switch


class CompleteExample(BoxLayout):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.spacing = 10.0
        self.bind(on_touch_down=self._on_touch_down_handler)
        widget_BBFC248F = Label(text="Event Handler Demo", font_size=24.0)
        self.add_widget(widget_BBFC248F)
        widget_71BB4D47 = Button(text="Button 1")
        widget_71BB4D47.bind(on_press=lambda instance: app.handle_button1 ())
        self.add_widget(widget_71BB4D47)
        widget_92DF895F = Button(text="Button 2")
        widget_92DF895F.bind(on_release=lambda instance: print ("Button 2 released!" ))
        self.add_widget(widget_92DF895F)
        my_switch = Switch()
        self.ids.my_switch = my_switch
        my_switch.bind(on_active=lambda instance: app.switch_changed ())
        self.add_widget(my_switch)

    def _on_touch_down_handler(self, instance):
        print ("Layout touched!" )