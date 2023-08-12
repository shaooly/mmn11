.data
	msg1: .asciiz "Enter the string(MAX 30 CHARS): "
	stringocta: .space 30
	wrongmsg: .asciiz "wrong input\n"
	NUM: .space 10
	sortarray: .space 10
.text
main:
	# promt the user to enter the string
	li $v0, 4
	la $a0, msg1
	syscall
	
	# load string into stringocta (max 30 chars) (1)
	li $v0, 8
	la $a0, stringocta
	li $a1, 30
	syscall
	
	# check if stringocta is valid (2)
	la $a1, stringocta # pass stringocta to is_valid
	jal is_valid	
	# now the number of pairs is in $v0
	
	
	# call the convert function on stringocta (3)
	move $t9, $v0 # t9 = v0 
	la $a0, stringocta
	la $a1, NUM
	move $a2, $v0
	jal convert
	
	# call the print function with NUM (4)
	la $a0, NUM
	move $a1, $v0
	jal print
	
	# call the sort function (5)
	la $a0, NUM
	move $a1, $t9 # we use t9 because we erased $v0 in the print func
	la $a2, sortarray
	jal sort
	
	
	
	# print \n
	li $a0, 10 # ascii code for \n
	li $v0, 11
	syscall
	
	# call the print array on sortarray (6)
	la $a0, sortarray
	jal print
	
	
	li $v0, 10
	syscall
	
	
is_valid:
	# define temporary variables for is_valid:
	# $a0 -> stringocta
	# $t0 -> number of pairs
	# $t1 -> iterate variable
	# %t2 -> current char
	# $t3 -> remainder
	# $s0 -> number of chars we passed through
	# $s1 -> 3
	# $s2 -> 2
	
	#### DECLARE REGISTERS ####
	li $s0, 0
	li $s1, 3
	li $s2, 2
	li $t0, 0 # start t0 to zero.
	move $t1, $a1 # %t1 = stringocta
	###########################
	
	#### START ITERATING ####
	iterate_string:
	lb $t2, ($t1) # $t2 = string[i] b
	beq $t2, '\n', found_end # reached end
	div $s0, $s1 # divide by 3 to get remainder
	mfhi $t3 
	
	beq $s2, $t3, checkdollar # if remainder == 2 (means we need to check if $t2 is $ char
	j check_num # means, that we are not in a mod 3 = 2 situation so we need a number not a dollar
checkdollar:
		bne $t2, '$', invalid # if $t2 is not $ when it needs to be, invalid code.
		add, $t0, $t0, 1 # pairs ++
		j iterate # we checked dollar, so no reason to check if it's a valid num base 8
check_num:
	bgt $t2, '7', invalid # if
	blt $t2, '0', invalid
	
iterate:
	add $t1, $t1, 1 # iterate
	add $s0, $s0, 1 # add char to char counter
	j iterate_string
	
	
	invalid:
	li $v0, 0  # number of pairs is 0 (invalid)
	li $v0, 4 # print "wrong input"
	la $a0, wrongmsg
	syscall
	j main
	found_end: # finish iteration
	div $s0, $s1
	mfhi $t3
	bnez $t3, invalid
	move $v0, $t0
	jr $ra


convert:
	#la $a0, stringocta
	#la $a1, NUM
	#move $a2, $v0
	
	# $t0 -> sum (number we will add to NUM)
	# $t1 -> iterate NUM array
	# $t2 -> iterate stringocta (i+=3)
	# $t3 -> pairs( check for the while
	# $t4 -> stringocta[$t2]
	
	move $t0, $zero
	move $t1, $a1 # t1 -> NUM
	move $t2, $a0 # t2 -> stringcota
	move $t3, $a2 # t3 = pairs
	
	convert_while:
	beqz $t3, end_convert_while
	move $t0, $zero # t0 = 0
	lb $t4, ($t2) # $t4 = stringocta[i]
	addi $t2, $t2, 1
	lb $t5, ($t2) # t5 = stringocta[i + 1] (load the right-most bit in the octa number
	subi $t4, $t4, '0'  # Convert ASCII '0'-'7' to 0-7
	subi $t5, $t5, '0'
	
	
	sll $t6, $t4, 3 # "multiply" by 8 shift by 3 bits
	add $t0, $t0, $t6 # add the 8^1 bit 
	add $t0, $t0, $t5 # add the 8^0 bit
	
	sb $t0, ($t1)
	addi $t1, $t1, 1
	addi $t2, $t2, 2 # i += 3(we added 1 earlier)
	
	sub $t3, $t3, 1
	j convert_while
	end_convert_while:
	jr $ra
	
	
print:
	#la $a0, NUM
	#la $a1, $v0
	#jal print
	
	# $t0 -> will hold the num we want to print
	# $t1 -> pointer (i) to the NUM array
	# $t2 -> will hold the pairs
	
	move $t1, $a0 # t1 = i
	move $t2, $a1 # t2 = pairs amount
	print_while:
	beqz $t2, end_print_while # if pairs left = 0, exit
	
	
	# print $t0 (NUM[i])
	lb $t0, ($t1) # $t0 = NUM[i]
	li $v0, 1
	move $a0, $t0
	syscall
	
	# print two spaces
	li $v0, 11
	li $a0, 32 # ASCII code for space
	syscall
	syscall
	
	# iterate
	
	addi $t1, $t1, 1
	subi $t2, $t2, 1
	j print_while
	end_print_while:
	jr $ra

	
sort:
	# $t0 -> pointer to NUM array
	# $t1 - > number of pairs we need to sort
	# $t2 -> pointer to sortarray
	# $t3 -> copy of number of pairs
	# $t4 -> pointer to sortarray + 1
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	copy_while:
	beqz $t1, end_copy_while
	
	# sortarray[i] = NUM[i]
	lb $t3, ($t0) 
	sb $t3, ($t2) 
	
	# iterate 
	add $t0, $t0, 1
	add $t2, $t2, 1
	sub $t1, $t1, 1
	j copy_while
	
	end_copy_while:
	
	## now inside sortarray we have a copy of NUM
	# reset variables:
	move $t1, $a1
	move $t2, $a2
	add $t4, $t2, 1
	
	move $t3, $t1

	sub $t3, $t3, 1 # start at pairs - 1 because we are constantly checking pairs + 1
	sub $t1, $t1, 1
	# now we can do bubblesort on sortarray to sort it.
	first_sort_while:
		beqz $t3, end_first_while # while i > 0
		move $t1, $a1 # j = pairs
		subi $t1, $t1, 1 # j = pairs - 1 ( we are checking pairs + 1)
	second_sort_while:
		beqz $t1, end_second_while # if $t1 = 0 end
		lb $s0, ($t2) # $s0 = sortarray[$t2]
		lb $s1, ($t4) # $s1 = sortarray[$t2 + 1]
		bgt $s0, $s1, swap # bubble sort procedure swap
		j iterate_second
	swap:
		sb $s0, ($t4) # sortarray[$t2 + 1] = sortarray[$t]
		sb $s1, ($t2)# sortarray[$t] = sortarray[$t2 + 1]
	
	iterate_second:
		add $t2, $t2, 1 # icrement i by 1
		add $t4, $t4, 1 # increment i + 1 by 1
		sub $t1, $t1, 1 # j--
	j second_sort_while
	end_second_while:
		move $t2, $a2 # resest the pointers to sortarray
		add $t4, $t2, 1 # reset the pointers to sortarray
		subi $t3, $t3, 1 # i--
		j first_sort_while
	end_first_while: # sorted
	jr $ra