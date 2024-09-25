package require greeter

foreach lang {en fr es} {
	puts [::greeter::greet "world" $lang]
}
