;
; BIOS-GRAPHICS
; Simple OS that just lets you move a cube on a screen.
;
; https://github.com/jayc3-3/BIOS-GRAPHICS
; Free for use and/or modification
;

;
; runtime.asm
; The main application
;

org 0x8000
bits 16

runtime:
mov al, 3
mov byte[console_cursory], al
mov bx, runtime_message
call console_print
mov bx, date_message
call console_print

call console_print.newline
mov bx, owner_message
call console_print
mov bx, github_message
call console_print

call keyboard_init

call console_print.newline
mov bx, reboot_notice
call console_print
mov bx, control_message
call console_print

mov bx, start_message
call console_print
call console_print.newline

pre_graphics_loop:
call keyboard_read
cmp al, 0
je .no_keypress

cmp al, 18
je reboot

cmp ah, 0x1C
je graphics_begin

.no_keypress:

jmp pre_graphics_loop

graphics_begin:
call graphics_enable

graphics_loop:
call keyboard_read
cmp al, 0
je .no_keypress

cmp al, 18
je reboot

call process_input

.no_keypress:

mov al, 0x7B
call graphics_clear

mov al, 0x26
mov bx, word[.cube_x]
mov dh, byte[.cube_y]
mov cx, 50
mov dl, 50
call graphics_rect

call graphics_swap
jmp graphics_loop

.cube_x: dw 0
.cube_y: db 0

reboot:
jmp 0xFFFF:0

runtime_message: db "Started BIOS-GRAPHICS rev. 002", 0
reboot_notice:   db "Press 'CTRL+R' to reboot at any time", 0
owner_message:   db "BIOS-GRAPHICS made by JayC3-3", 0
github_message:  db "https://github.com/jayc3-3/BIOS-GRAPHICS", 0
date_message:    db "Software dated Oct. 01, 2023", 0
start_message:   db "Press 'Enter' to start", 0
control_message: db "Use the 'WASD' keys to control the cube", 0

%include "src/console.asm"
%include "src/graphics.asm"
%include "src/keyboard.asm"

process_input: ; Input: AH = INT 16h scancode; No output
push bx

cmp ah, 0x11
je .up
cmp ah, 0x1F
je .down
cmp ah, 0x1E
je .left
cmp ah, 0x20
je .right

.done:
pop bx
ret

.up:
mov bl, byte[graphics_loop.cube_y]
cmp bl, 0
je .up_over

sub bl, 5
mov byte[graphics_loop.cube_y], bl

jmp .done

.up_over:
xor bl, bl
mov byte[graphics_loop.cube_y], bl

jmp .done

.down:
mov bl, byte[graphics_loop.cube_y]
cmp bl, 150
je .down_over

add bl, 5
mov byte[graphics_loop.cube_y], bl

jmp .done

.down_over:
mov bl, 150
mov byte[graphics_loop.cube_y], bl

jmp .done

.left:
mov bx, word[graphics_loop.cube_x]
cmp bx, 0
je .left_over

sub bx, 5
mov word[graphics_loop.cube_x], bx

jmp .done

.left_over:
xor bx, bx
mov word[graphics_loop.cube_x], bx

jmp .done

.right:
mov bx, word[graphics_loop.cube_x]
cmp bx, 270
je .right_over

add bx, 5
mov word[graphics_loop.cube_x], bx

jmp .done

.right_over:
mov bx, 270
mov word[graphics_loop.cube_x], bx

jmp .done

times 16384 - ($ - runtime) db 0