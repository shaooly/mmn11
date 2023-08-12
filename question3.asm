#################
# pesudo
# end = str.length
# i = 0
# while(end > 0)
#	i = 0
#	while(i < end)
#		print(str[i])
#		i++
#	end--
#
#
#
#
#################




.data
	msg1: .asciiz "Enter the string(30 chars long): "
	buffer: .space 30
	newline: .asciiz "\n"
	
.text
main:
	# promt the user to enter the string
	li $v0, 4
	la $a0, msg1
	syscall
	
	# load string into buffer (max 30 chars)
	li $v0, 8
	la $a0, buffer
	li $a1, 30
	syscall
	
	la $t1, buffer # $t1 = string start address
	
	# find the end of the string and place the address to the end in $t1
	
find_end:
	lb $t2, ($t1) # $t2 = string[i] b
	beqz $t2, found_end # if string[i] is 0, means we found the end of the string
	add $t1, $t1, 1
	j find_end
	
found_end: # $t1 points to the end of the string
	la $t2, buffer # i = 0


# $t2 = i
# $t1 = end of string
check_end: # while end > start
	la, $t2, buffer # i = 0
	beq $t1, $t2, finish # check if end != buffer
print_string:
	beq $t2, $t1, finish_print # i < end
	lb $a0, ($t2) # load string[i] into $a0
	li $v0, 11 
	syscall # print
	add $t2, $t2, 1 # i++
	j print_string

finish_print:	
	sub $t1, $t1, 1
	li $v0, 4 # print newline
	la $a0, newline # print newline
	syscall # print newline
	j check_end
finish:
	li $v0, 10
	syscall # reached end, exit
