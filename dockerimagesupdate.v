#!/usr/bin/env -S v run

import os

const (
	headers = ['REPOSITORY', 'TAG', 'IMAGE ID', 'CREATED', 'SIZE']
)

fn header_start_positions(header string) []int {
	mut result := []int{}
	for h in headers {
		if pos := header.index(h) {
			result << pos
		}
	}
	return result
}

fn get_field(s string, positions []int, index int) string {
	len := positions.len
	mut result := ''
	if index >= 0 && index < len {
		if index == len - 1 {
			result = s[positions[index]..]
		} else {
			result = s[positions[index]..positions[index + 1]]
		}
	}
	return result
}

fn main() {
	println('dockerimagesupdate v0.0.2 by Zhuo Nengwen at 2022-06-17')
	images := os.execute_or_exit('sudo docker images')
	if images.exit_code == 0 {
		lines := images.output.split_into_lines()
		header := lines[0]
		positions := header_start_positions(header)
		for line in lines[1..] {
			mut matched := true
			mut cmd := ''
			tag := get_field(line, positions, 1).trim_space()
			match tag {
				'<none>' {
					id := get_field(line, positions, 2).trim_space()
					cmd = 'sudo docker image rm $id -f'
				}
				'latest' {
					name := get_field(line, positions, 0).trim_space()
					cmd = 'sudo docker pull $name'
				}
				else {
					matched = false
				}
			}

			if matched {
				println('\n$cmd')
				os.system(cmd)
			}
		}
	}
}
