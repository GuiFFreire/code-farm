extends Control
class_name TransicaoCenario

@onready var circulo := $CirculoTransicao
@onready var shader := circulo.material as ShaderMaterial

signal transicao_finalizada

func iniciar_transicao(callback: Callable):
	shader.set_shader_parameter("radius", 0.0)
	visible = true
	circulo.visible = true
	shader.set_shader_parameter("radius", 1.5)

	var tween = create_tween()
	tween.tween_property(shader, "shader_parameter/radius", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_ao_escurecer_completo").bind(callback))

func _ao_escurecer_completo(callback: Callable):
	callback.call_deferred()  # Garantir que ocorra após o frame atual

	var tween = create_tween()
	tween.tween_property(shader, "shader_parameter/radius", 1.5, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_ao_clarear_completo"))

func _ao_clarear_completo():
	circulo.visible = false
	visible = false
	emit_signal("transicao_finalizada")
