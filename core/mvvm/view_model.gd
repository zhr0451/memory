class_name ViewModel extends RefCounted
## Базовый класс ViewModel. Не должен ссылаться на Node.


## Вызывается View при привязке; переопределяйте для начальной инициализации.
func activate() -> void:
	pass


## Вызывается View при выходе из дерева; освобождайте подписки.
func deactivate() -> void:
	pass
