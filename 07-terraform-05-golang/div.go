package main

import "fmt"

func div3(max int) []int {
	var output []int
	for i := 1; i <= max; i++ {
		if i%3 == 0 {
			output = append(output, i)
		}
	}

	return output
}

func main() {
	var div = div3(100)
	fmt.Println(div)
}
