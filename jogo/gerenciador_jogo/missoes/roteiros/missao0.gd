extends RoteiroMissao

func executar() -> void:
	# 1. Encontra o diário no mapa e faz ele "sumir" da tela
	var diario = mundo_jogo.obter_elemento("Missao0")
	if diario:
		diario.hide()
		diario.process_mode = PROCESS_MODE_DISABLED # Desativa a colisão
	
	# 2. Emite o sinal para abrir o glossário direto na tela do jogador
	Global.emit_signal("abrir_glossario")
	
	# 3. Pausa o roteiro da missão e espera o jogador ler tudo e fechar o livro
	_pausar_missao()
	await aguardar_retomar() 
	
	# Isso vai fazer a missão virar 1, salvar o jogo 
	concluir_missao()
