extends RichTextLabel


# Variables
var dialog = [""]

var within_range = false

var page = 0


# Functions
func _ready():
	set_bbcode(dialog[page])
	set_visible_characters(0)

func _physics_process(delta):
	if Input.is_action_just_pressed("Interact") && within_range:
		if get_visible_characters() >= get_total_character_count():
			if page < dialog.size():
				set_bbcode(dialog[page])
				page += 1
				set_visible_characters(0)
				if page >= dialog.size():
					page = 0
		else:
			if visible == true:
				set_visible_characters(get_total_character_count())
			else:
				visible = true
	
	

func _on_Timer_timeout():
	set_visible_characters(get_visible_characters()+1)
