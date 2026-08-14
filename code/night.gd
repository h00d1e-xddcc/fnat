extends Resource
class_name fnat_night

@export var diff : Array[int] = [0,0,0,0,0,0,0,0,0]
@export var chimera : int = 0 # chimera
@export var noise : int = 0 # noise
@export var nerd : int = 0 # nerd
@export var endo : int = 0 # THE MIMIC
@export var bear : int = 0 # bear
@export var nchimera : int = 0 # nightmare_chimera
@export var gnoise : int = 0 # golden_noise
@export var viruses : int = 0 # ad_on_screen
@export var vissy : int = 0 # minigames_or_smt_good
@export var pg_sm : int = 0 # photo_girl_and_
@export var pearto : int = 0 # pearteto
@export var tt : int = 0 # funny_toy
@export var hakua : int = 0 # idunoo
@export var alien : int = 0 #hi_alien_kmmwejfnon5_fagg_aaaaaa_pearteto
# -1 disable
# 0-5 eas
# 6-12 med
# 13-19 hard
# 20-25 ext

@export var is_can_be_more_difficult : bool = false # can_pg_increase_difficulty
@export var is_can_be_ultimate_difficult : bool = false # can_nir_absolute_difficulty
@export var is_static_diffucult : bool = true # can_ai_lvl_scaling_for_hours
@export var is_can_random_event : bool = true # thunder_or_etc_random_happend
@export var true_night : bool = false # add night_count_for_compite

@export var start_power : int = 57
@export var start_usage : float = 1.75
@export var start_night : int = 0
@export var start_time : int = 0
@export var phone_call_path : String

@export var words : Array[String] = ["bamboozled", "holyday", "face", "manjaro", "pearto", "tetomato", "color", "pipe", "poteto", "ritual", "pride", "ragebait", "you_moma", "america", "france", "chicken_jokey", "turbulence", "motomoto", "ancient", "dune", "chad", "peter_griffin", "pls_do_not_the_car", "fortnight", "nuclear", "throne", "open_suse", "sunflower", "monday", "siegessaule", "perturabo", "mann", "g13", "2fort"]
# to add some words in `Teto Word Of The Day`, just add some words in array, like there. Avoid letters `w,s` and `Spacebar`
# для добавления слов в `Слово Тето Сегодня` просто добавь слова в массив, прямо как там. Избегать букв `ц, ы` и пробела
