package main

import "fmt"

func minNumber(arr []int) int {
	min := arr[0]

	if len(arr) > 1 {
		for i := 1; i < len(arr); i++ {
			if arr[i] < min {
				min = arr[i]
			}
		}
	}

	return min
}

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	min := minNumber(x)
	fmt.Println("min number", min)
}
