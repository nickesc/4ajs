extends CanvasLayer

func _on_coin_collected(coins):
    $Coins.text = str(coins)

func _on_health_updated(health):
    $Health.text = str(health) + "%"
