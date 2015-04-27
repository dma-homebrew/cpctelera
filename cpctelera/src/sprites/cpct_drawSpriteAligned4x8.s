;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2014-2015 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------
.module cpct_sprites

;
;########################################################################
;### FUNCTION: cpct_drawSpriteAligned4x8                              ###
;########################################################################
;### Copies a 4x8-bytes sprite from its original memory storage       ###
;### position to a video memory position (taking into account video   ###
;### memory distribution). This function asumes that the destination  ###
;### in the video memory will be the starting line of a character.    ###
;### (First byte line of video memory, where characters from the 25   ###
;###  lines start. First 2000 bytes, C000 to C7D0, in bank 4)         ###
;### It also asumes that the sprite is a solid entity and all of its  ###
;### bytes are stored consecutively: they are copied as they are.     ###
;########################################################################
;### INPUTS (4 Bytes)                                                 ###
;###  * (2B) Source Sprite Pointer (32-byte vector with pixel data)   ###
;###  * (2B) Destiny aligned video memory start location              ###
;########################################################################
;### EXIT STATUS                                                      ###
;###  Destroyed Register values: AF, BC, DE, HL                       ###
;########################################################################
;### MEASURED TIME                                                    ###
;###  MEMORY:  30 bytes                                               ###
;###  TIME:   927 cycles                                              ###
;########################################################################
;
_cpct_drawSpriteAligned4x8::
   ;; GET Parameters from the stack (Push+Pop is faster than referencing with IX)
   pop  af                 ;; [10] AF = Return Address
   pop  hl                 ;; [10] HL = Source address
   pop  de                 ;; [10] DE = Destination address
   push de                 ;; [11] Leave the stack as it was
   push hl                 ;; [11] 
   push af                 ;; [11] 

   ;; Copy 8 lines of 4 bytes width
   ld    a, #8             ;; [ 7] We have to draw 8 lines of sprite
   jp dsa48_first_line     ;; [10] First line does not need to do math to start transfering data. 

dsa48_next_line:
   ;; Move to the start of the next line
   ex   de, hl             ;; [ 4] Make DE point to the start of the next line of pixels in video memory, by adding BC
   add  hl, bc             ;; [11] (We need to interchange HL and DE because DE does not have ADD)
   ex   de, hl             ;; [ 4]

dsa48_first_line:
   ;; Draw a sprite-line of 4 bytes
   ld   bc, #0x800         ;; [10] 800h bytes is the distance to the start of the first pixel in the next line in video memory (it will be decremented by 1 by each LDI)
   ldi                     ;; [16] <|Copy 4 bytes with (DE) <- (HL) and decrement BC (distance is 1 byte less as we progress up)
   ldi                     ;; [16]  |
   ldi                     ;; [16]  |
   ldi                     ;; [16] <|

   ;; Repeat for all the lines
   dec   a                 ;; [ 4] A = A - 1 (1 more line completed)
   jp   nz, dsa48_next_line;; [10] 

   ret                     ;; [10]