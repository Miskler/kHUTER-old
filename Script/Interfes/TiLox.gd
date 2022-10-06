extends Control

onready var CraftMeny: Control = $"..//CraftMeny" #две точки - это шаг выше по иерархии, то есть - "перейди к владельцу и в нем найди ноду Interf"
onready var Interf: Control = $"../Interf"
onready var Nadeto: Control = $"../Nadeto"
onready var MenyInter: Control = $"../MenyInter"
onready var Meny: Control = $"../Meny"
onready var CrovatM: Control = $"../CrovatM"
onready var Comp: Control = $"../Comp"
onready var SettingData = $"/root/rootGame/Node/SettingData"

onready var GG = get_node("../../../../GG")

func _ready():
	if G.ru == false:
		$Label.text = "time:"
		$Label2.text = "cause:"
		$VBoxContainer/Button2.text = "quit"
		$VBoxContainer/Button3.text = "load"

func _process(_delta):
	if GG.sdorov <= 0 or GG.ymer == true:
		var op = false
		$".".show()
		CraftMeny.hide()
		Interf.hide()
		Nadeto.hide()
		CrovatM.hide()
		Comp.hide()
		MenyInter.hide()
		GG.UI["intermeny"] = false
		Meny.hide()
		GG.UI["vcl"] = false
		if op == false:
			op = true
			opca()

func opca():
	$Label3.text = str(SettingData.time) + ":00"
	if G.ru == true:
		if GG.visota == true:
			$Label4.text = "упал"
		elif GG.noSleep == true:
			$Label4.text = "не спал"
		elif GG.golodyha == true:
			$Label4.text = "голод"
		else:
			$Label4.text = "убийство"
	else:
		if GG.visota == true:
			$Label4.text = "fell"
		elif GG.noSleep == true:
			$Label4.text = "did not sleep"
		elif GG.golodyha == true:
			$Label4.text = "hunger"
		else:
			$Label4.text = "murder"
