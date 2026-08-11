// Package main demonstrates the C++ lexer categories used by Go mode.
package main

import (
	"fmt"
	"strings"
)

const version = 17

type Greeter struct {
	Name string
}

func (g Greeter) Message(prefix string) string {
	if g.Name == "" {
		return `raw string\nwithout escapes`
	}
	return fmt.Sprintf("%s, %s: %d", prefix, g.Name, version)
}

func main() {
	greeter := Greeter{Name: "mrbmacs"}
	for _, word := range strings.Fields(greeter.Message("hello")) {
		fmt.Println(word)
	}
}
