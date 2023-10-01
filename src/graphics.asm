;
; BIOS-GRAPHICS
; Simple 'Operating System' that just lets you move a cube on a screen.
;
; https://github.com/jayc3-3/BIOS-GRAPHICS
; Free for use and/or modification
;

;
; graphics.asm
; INT 10h graphical functions
;

%define graphics_framebuffer 0xA000
%define graphics_back_buffer 0x1000

; NOTE: So-called 'graphics mode' can be disabled by calling either 'console_init' or 'screen_init'
graphics_enable: ; No input; No output
push ax

xor ah, ah
mov al, 0x13
int 0x10

pop ax
ret

graphics_swap: ; No input; No output
push cx
push dx
push si
push di
push fs
push gs

mov si, graphics_back_buffer
mov fs, si
xor si, si

mov di, graphics_framebuffer
mov gs, di
xor di, di

xor cx, cx

.loop:
cmp cx, 0xFA00
je .done

mov dl, byte[fs:si]
mov byte[gs:di], dl

inc si
inc di
inc cx
jmp .loop

.done:
pop gs
pop fs
pop di
pop si
pop dx
pop cx
ret

graphics_pixel: ; Input: AL = Color, CX = X position, DX = Y position; No output
push ax
push bx
push cx
push dx
push fs
push ax

mov bx, graphics_back_buffer
push bx
mov fs, bx
mov bx, cx

mov cx, 320
mov ax, dx
mul cx

add bx, ax
pop ax
add ax, dx
mov fs, ax

pop ax
mov byte[fs:bx], al

pop fs
pop dx
pop cx
pop bx
pop ax
ret

graphics_clear: ; Input: AL = Color; No output
push bx
push cx
push fs

mov bx, graphics_back_buffer
mov fs, bx
xor bx, bx

xor cx, cx

.loop:
cmp cx, 64000
je .done

mov byte[fs:bx], al

inc cx
inc bx
jmp .loop

.done:
pop fs
pop cx
pop bx
ret

graphics_rect: ; Input: AL = Color, BX = Rect X, CX = Rect width, DH = Rect Y, DL = Rect height; No output
push ax
push bx
push cx
push dx
push fs

push bx
mov bx, graphics_back_buffer
mov fs, bx
pop bx

push ax
push dx
xor dl, dl
shr dx, 8
mov ax, 320
mul dx
add bx, ax
pop dx
pop ax

.loop_x:
cmp cx, 0
je .done

push dx
push bx

.loop_y:
cmp dl, 0
je .loop_y_done

mov byte[fs:bx], al
inc bx

dec dl
jmp .loop_y

.loop_y_done:

pop bx
pop dx

add bx, 320

dec cx
jmp .loop_x

.done:
pop fs
pop dx
pop cx
pop bx
pop ax
ret