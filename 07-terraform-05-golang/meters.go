package main

import "fmt"

func metersToFeet(meters float32) float32 {
	feet := 0.3048 * meters
	return feet
}

func main() {
	fmt.Print("Enter meters: ")
	var meters float32
	fmt.Scanf("%f", &meters)

	feet := metersToFeet(meters)

	fmt.Println(feet, "feet")
}
