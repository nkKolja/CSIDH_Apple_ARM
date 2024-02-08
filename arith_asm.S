/****************************************************************************
*   Efficient implementation of finite field arithmetic over p511 on ARMv8
*                   Constant-time Implementation of CSIDH
*
*   Author: Amir Jalali                     ajalali2016@fau.edu
*                       
*                       All rights reserved   
*****************************************************************************/

//; sFormat function and variable names for Mac OS X
#if defined(__APPLE__)
    #define fmt(f)    _##f
#else
    #define fmt(f)    f
#endif

.text
.align 4

p511:
.quad 0x1b81b90533c6c87b
.quad 0xc2721bf457aca835
.quad 0x516730cc1f0b4f25
.quad 0xa7aac6c567f35507
.quad 0x5afbfcc69322c9cd
.quad 0xb42d083aedc88c42
.quad 0xfc8ab0d15e3e4c4a
.quad 0x65b48e8f740f89bf

minus_p511_inverse:
.quad 0x66c1301f632e294d


inv_min_p_mod_r: 
    .quad 0x66c1301f632e294d
big_p: 
    .quad 0x1b81b90533c6c87b, 0xc2721bf457aca835, 0x516730cc1f0b4f25, 0xa7aac6c567f35507
    .quad 0x5afbfcc69322c9cd, 0xb42d083aedc88c42, 0xfc8ab0d15e3e4c4a, 0x65b48e8f740f89bf


.macro schoolbook_compact_registers_first
    mul     x10, x3, x7
    umulh   x12, x3, x7
    
    mul     x14, x4, x7
    umulh   x16, x4, x7
    
    mul     x30, x5, x7
    umulh   x20, x5, x7

    mul     x22, x6, x7
    umulh   x24, x6, x7

    adds    x12, x12, x14
    adcs    x16, x16, x30
    adcs    x20, x20, x22

    ldp     x3, x4, [x0, #32]
    ldp     x5, x6, [x0, #48]

    mul     x25, x3, x7
    umulh   x26, x3, x7

    mul     x27, x4, x7
    umulh   x14, x4, x7

    mul     x30, x5, x7
    umulh   x22, x5, x7

    mul     x3, x6, x7
    umulh   x4, x6, x7

    adcs    x24, x24, x25
    adcs    x26, x26, x27
    adcs    x14, x14, x30
    adcs    x22, x22, x3
    adc     x4, x4, xzr
.endm

.macro schoolbook_compact_registers_second
    ldr     x3, p511
    ldr     x4, p511 + 8
    ldr     x5, p511 + 16
    ldr     x6, p511 + 24

    mul     x10, x3, x28
    umulh   x12, x3, x28
    
    mul     x14, x4, x28
    umulh   x16, x4, x28
    
    mul     x30, x5, x28
    umulh   x20, x5, x28

    mul     x22, x6, x28
    umulh   x24, x6, x28

    adds    x12, x12, x14
    adcs    x16, x16, x30
    adcs    x20, x20, x22

    ldr     x3, p511 + 32
    ldr     x4, p511 + 40
    ldr     x5, p511 + 48
    ldr     x6, p511 + 56
    
    mul     x25, x3, x28
    umulh   x26, x3, x28

    mul     x27, x4, x28
    umulh   x14, x4, x28

    mul     x30, x5, x28
    umulh   x22, x5, x28 
    
    mul     x3, x6, x28
    umulh   x4, x6, x28 

    adcs    x24, x24, x25
    adcs    x26, x26, x27
    adcs    x14, x14, x30
    adcs    x22, x22, x3
    adc     x4, x4, xzr
.endm

.macro stack_pointer_st
    sub   sp,  sp, #96
    stp   x19, x20, [sp]
    stp   x21, x22, [sp, #16]
    stp   x23, x24, [sp, #32]
    stp   x25, x26, [sp, #48]
    stp   x27, x28, [sp, #64]
    str   x30, [sp, #80]
.endm

.macro stack_pointer_ld
    ldp   x19, x20, [sp]
    ldp   x21, x22, [sp, #16]
    ldp   x23, x24, [sp, #32]
    ldp   x25, x26, [sp, #48]
    ldp   x27, x28, [sp, #64]
    ldr   x30, [sp, #80]
    add   sp,  sp,  #96
.endm

.global fmt(fp_add_512)
.global fmt(fp_sub_512)
.global fmt(mp_add_512)
.global fmt(mp_sub_512)
.global fmt(mp_mul_u64)
.global fmt(fp_mul_mont_512)

fmt(fp_add_512):
    stack_pointer_st

    ldp     x3, x4,   [x0]
    ldp     x5, x6,   [x0,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x9, x10,  [x0,#48]
     
    ldp     x11, x12, [x1]
    ldp     x13, x14, [x1,#16]
    ldp     x15, x16, [x1,#32]
    ldp     x17, x30, [x1,#48]  

    adds    x3, x3, x11
    adcs    x4, x4, x12
    adcs    x5, x5, x13
    adcs    x6, x6, x14
    adcs    x7, x7, x15
    adcs    x8, x8, x16
    adcs    x9, x9, x17
    adcs    x10, x10, x30

    ldr     x11, p511
    ldr     x12, p511 + 8
    ldr     x13, p511 + 16
    ldr     x14, p511 + 24
    ldr     x15, p511 + 32
    ldr     x16, p511 + 40
    ldr     x17, p511 + 48
    ldr     x30, p511 + 56

    subs    x3, x3, x11
    sbcs    x4, x4, x12
    sbcs    x5, x5, x13
    sbcs    x6, x6, x14
    sbcs    x7, x7, x15
    sbcs    x8, x8, x16
    sbcs    x9, x9, x17
    sbcs    x10, x10, x30
    sbc     x19, xzr, xzr

    and     x11, x11, x19
    adds    x3, x3, x11
    and     x12, x12, x19
    adcs    x4, x4, x12
    and     x13, x13, x19
    adcs    x5, x5, x13
    and     x14, x14, x19
    adcs    x6, x6, x14
    and     x15, x15, x19
    adcs    x7, x7, x15
    and     x16, x16, x19
    adcs    x8, x8, x16
    and     x17, x17, x19
    adcs    x9, x9, x17 
    and     x30, x30, x19
    adcs    x10, x10, x30

    stp     x3, x4, [x2]
    stp     x5, x6, [x2,#16]
    stp     x7, x8, [x2,#32]
    stp     x9, x10, [x2,#48]
    
    stack_pointer_ld
    ret

fmt(fp_sub_512):
    stack_pointer_st

    ldp     x3, x4,   [x0]
    ldp     x5, x6,   [x0,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x9, x10,  [x0,#48]
     
    ldp     x11, x12, [x1]
    ldp     x13, x14, [x1,#16]
    ldp     x15, x16, [x1,#32]
    ldp     x17, x30, [x1,#48]

    subs    x3, x3, x11
    sbcs    x4, x4, x12
    sbcs    x5, x5, x13
    sbcs    x6, x6, x14
    sbcs    x7, x7, x15
    sbcs    x8, x8, x16
    sbcs    x9, x9, x17
    sbcs    x10, x10, x30
    sbc     x19, xzr, xzr

    ldr     x11, p511
    ldr     x12, p511 + 8
    ldr     x13, p511 + 16
    ldr     x14, p511 + 24
    ldr     x15, p511 + 32
    ldr     x16, p511 + 40
    ldr     x17, p511 + 48
    ldr     x30, p511 + 56

    and     x11, x11, x19
    adds    x3, x3, x11
    and     x12, x12, x19
    adcs    x4, x4, x12
    and     x13, x13, x19
    adcs    x5, x5, x13
    and     x14, x14, x19
    adcs    x6, x6, x14
    and     x15, x15, x19
    adcs    x7, x7, x15
    and     x16, x16, x19
    adcs    x8, x8, x16
    and     x17, x17, x19
    adcs    x9, x9, x17 
    and     x30, x30, x19
    adcs    x10, x10, x30
    
    stp     x3, x4, [x2]
    stp     x5, x6, [x2,#16]
    stp     x7, x8, [x2,#32]
    stp     x9, x10, [x2,#48]
    
    stack_pointer_ld
    ret

fmt(mp_add_512):
    stack_pointer_st

    ldp     x3, x4,   [x0]
    ldp     x5, x6,   [x0,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x9, x10,  [x0,#48]
     
    ldp     x11, x12, [x1]
    ldp     x13, x14, [x1,#16]
    ldp     x15, x16, [x1,#32]
    ldp     x17, x30, [x1,#48]

    adds    x3, x3, x11
    adcs    x4, x4, x12
    adcs    x5, x5, x13
    adcs    x6, x6, x14
    adcs    x7, x7, x15
    adcs    x8, x8, x16
    adcs    x9, x9, x17
    adc    x10, x10, x30

    stp     x3, x4, [x2]
    stp     x5, x6, [x2,#16]
    stp     x7, x8, [x2,#32]
    stp     x9, x10, [x2,#48]
    
    stack_pointer_ld
    ret

fmt(mp_sub_512):
    stack_pointer_st

    ldp     x3, x4,   [x0]
    ldp     x5, x6,   [x0,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x9, x10,  [x0,#48]
     
    ldp     x11, x12, [x1]
    ldp     x13, x14, [x1,#16]
    ldp     x15, x16, [x1,#32]
    ldp     x17, x30, [x1,#48]

    subs    x3, x3, x11
    sbcs    x4, x4, x12
    sbcs    x5, x5, x13
    sbcs    x6, x6, x14
    sbcs    x7, x7, x15
    sbcs    x8, x8, x16
    sbcs    x9, x9, x17
    sbcs    x10, x10, x30
    mov     x0, #0
    sbc     x0, x0, x0

    stp     x3, x4, [x2]
    stp     x5, x6, [x2,#16]
    stp     x7, x8, [x2,#32]
    stp     x9, x10, [x2,#48]
    
    stack_pointer_ld
    ret

fmt(mp_mul_u64):
    stack_pointer_st

    ldp     x3, x4,   [x0]
    ldp     x5, x6,   [x0,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x9, x10,  [x0,#48]
    
    mul     x12, x3, x1
    umulh   x13, x3, x1

    mul     x14, x4, x1
    umulh   x15, x4, x1         

    mul     x16, x5, x1
    umulh   x17, x5, x1         

    mul     x30, x6, x1
    umulh   x19, x6, x1         

    mul     x20, x7, x1
    umulh   x21, x7, x1         

    mul     x22, x8, x1
    umulh   x23, x8, x1         

    mul     x24, x9, x1
    umulh   x25, x9, x1         

    mul     x26, x10, x1
    umulh   x27, x10, x1

    adds    x13, x13, x14
    adcs    x15, x15, x16
    adcs    x17, x17, x30
    adcs    x19, x19, x20
    adcs    x21, x21, x22
    adcs    x23, x23, x24
    adc     x25, x25, x26

    stp     x12, x13, [x2]
    stp     x15, x17, [x2, #16]
    stp     x19, x21, [x2, #32]
    stp     x23, x25, [x2, #48]

    stack_pointer_ld

    ret        
































































/* C = C + AI * B */
.macro mul_8x1, AI, C0, C1, C2, C3, C4, C5, C6, C7, C8, B0, B1, B2, B3, B4, B5, B6, B7, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, CARRY_REG 

    mul     \T0, \AI, \B0
    umulh   \T1, \AI, \B0
    mul     \T2, \AI, \B2
    umulh   \T3, \AI, \B2
    mul     \T4, \AI, \B4
    umulh   \T5, \AI, \B4
    mul     \T6, \AI, \B6
    umulh   \T7, \AI, \B6

    adds    \C0, \C0, \T0
    adcs    \C1, \C1, \T1
    adcs    \C2, \C2, \T2
    adcs    \C3, \C3, \T3
    adcs    \C4, \C4, \T4
    adcs    \C5, \C5, \T5
    adcs    \C6, \C6, \T6
    adcs    \C7, \C7, \T7
    adc     \C8, \C8, xzr

    mul     \T0, \AI, \B1
    umulh   \T1, \AI, \B1
    mul     \T2, \AI, \B3
    umulh   \T3, \AI, \B3
    mul     \T4, \AI, \B5
    umulh   \T5, \AI, \B5
    mul     \T6, \AI, \B7
    umulh   \T7, \AI, \B7

    adds    \C1, \C1, \T0
    adcs    \C2, \C2, \T1
    adcs    \C3, \C3, \T2
    adcs    \C4, \C4, \T3
    adcs    \C5, \C5, \T4
    adcs    \C6, \C6, \T5
    adcs    \C7, \C7, \T6
    adc     \C8, \C8, \T7

.endm 



    /* mul step */
.macro mul_step, K, C0, C1, C2, C3, C4, C5, C6, C7, C8, B0, B1, B2, B3, B4, B5, B6, B7, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11 

    ldr \T0, [sp, #16]  // load B addr pointer 
    ldp \B0, \B1, [\T0, #0]  // load B 
    ldp \B2, \B3, [\T0, #16]  // load B 
    ldp \B4, \B5, [\T0, #32]  // load B 
    ldp \B6, \B7, [\T0, #48]  // load B 

    ldr \T1, [sp, #8]  // load A addr pointer 
    ldr \T11, [\T1 , 8*\K] // load AI 

    /* C ← C + ai B */
    mul_8x1 \T11, \C0, \C1, \C2, \C3, \C4, \C5, \C6, \C7, \C8, \B0, \B1, \B2, \B3, \B4, \B5, \B6, \B7, \T0, \T1, \T2, \T3, \T4, \T5, \T6, \T7, \T8, \T9, \T10
    /* q ← mu * C mod r */
    ; adrp \T11, inv_min_p_mod_r@PAGE
    ; add \T11, \T11, inv_min_p_mod_r@PAGEOFF
    ; ldr \T11, [\T11, #0]  // load inv_min_p_mod_r 
    ldr \T11, inv_min_p_mod_r
    mul \T11, \T11, \C0  // mul C0 with inv_min_p_mod_r = q 

    /* C ← C + q p */
    ; adrp \T0, big_p@PAGE
    ; add \T0, \T0, big_p@PAGEOFF
    ; ldp \B0, \B1, [\T0, #0]  // load B 
    ; ldp \B2, \B3, [\T0, #16]  // load B 
    ; ldp \B4, \B5, [\T0, #32]  // load B 
    ; ldp \B6, \B7, [\T0, #48]  // load B 

    ldr \B0, big_p
    ldr \B1, big_p + 8
    ldr \B2, big_p + 16
    ldr \B3, big_p + 24
    ldr \B4, big_p + 32
    ldr \B5, big_p + 40
    ldr \B6, big_p + 48
    ldr \B7, big_p + 56

    mul_8x1 \T11, \C0, \C1, \C2, \C3, \C4, \C5, \C6, \C7, \C8, \B0, \B1, \B2, \B3, \B4, \B5, \B6, \B7, \T0, \T1, \T2, \T3, \T4, \T5, \T6, \T7, \T8, \T9, \T10
    /* C <- C / r */
    ; mov \C0, \C1  // move C1 to C0 
    ; mov \C1, \C2  // move C2 to C1 
    ; mov \C2, \C3  // move C3 to C2 
    ; mov \C3, \C4  // move C4 to C3 
    ; mov \C4, \C5  // move C5 to C4 
    ; mov \C5, \C6  // move C6 to C5 
    ; mov \C6, \C7  // move C7 to C6 
    ; mov \C7, \C8  // move C8 to C7 
    ; eor \C8, \C8, \C8

.endm 


fmt(fp_mul_mont_512):
    mov x3, x2
    mov x2, x1
    mov x1, x0
    mov x0, x3

    /* save variables on stack */
    sub sp, sp, #112
    stp x0, x1, [sp, #0]
    stp x2, x19, [sp, #16]
    stp x20, x21, [sp, #32]
    stp x22, x23, [sp, #48]
    stp x24, x25, [sp, #64]
    stp x26, x27, [sp, #80]
    stp x28, x30, [sp, #96]

    /* set C to 0 */
    eor x21, x21, x21
    eor x22, x22, x22
    eor x23, x23, x23
    eor x24, x24, x24
    eor x25, x25, x25
    eor x26, x26, x26
    eor x27, x27, x27
    eor x28, x28, x28
    eor x30, x30, x30

    mul_step 0, x21, x22, x23, x24, x25, x26, x27, x28, x30, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 1, x22, x23, x24, x25, x26, x27, x28, x30, x21, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 2, x23, x24, x25, x26, x27, x28, x30, x21, x22, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 3, x24, x25, x26, x27, x28, x30, x21, x22, x23, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 4, x25, x26, x27, x28, x30, x21, x22, x23, x24, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 5, x26, x27, x28, x30, x21, x22, x23, x24, x25, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 6, x27, x28, x30, x21, x22, x23, x24, x25, x26, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 
    mul_step 7, x28, x30, x21, x22, x23, x24, x25, x26, x27, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x19, x20 

    ; adrp x8, big_p@PAGE
    ; add x8, x8, big_p@PAGEOFF
    ; ldp x0, x1, [x8, #0]  // load P 
    ; ldp x2, x3, [x8, #16]  // load P 
    ; ldp x4, x5, [x8, #32]  // load P 
    ; ldp x6, x7, [x8, #48]  // load P 

    ldr x0, big_p
    ldr x1, big_p + 8

    ldr x2, big_p + 16
    ldr x3, big_p + 24

    subs x30, x30, x0  // sub C0 with P0 
    sbcs x21, x21, x1  // sub C1 with P1 

    sbcs x22, x22, x2  // sub C2 with P2 
    sbcs x23, x23, x3  // sub C3 with P3 

    ldr x4, big_p + 32
    ldr x5, big_p + 40

    ldr x6, big_p + 48
    ldr x7, big_p + 56

    sbcs x24, x24, x4  // sub C4 with P4 
    sbcs x25, x25, x5  // sub C5 with P5 

    sbcs x26, x26, x6  // sub C6 with P6 
    sbcs x27, x27, x7  // sub C7 with P7 
    sbcs x8, xzr, xzr  // carry into temp0 

    and x0, x0, x8  // and P0 with temp0 
    and x1, x1, x8  // and P1 with temp0 
    and x2, x2, x8  // and P2 with temp0 
    and x3, x3, x8  // and P3 with temp0 
    and x4, x4, x8  // and P4 with temp0 
    and x5, x5, x8  // and P5 with temp0 
    and x6, x6, x8  // and P6 with temp0 
    and x7, x7, x8  // and P7 with temp0 
    ldr x9, [sp, #0]  // load dest addr pointer 

    adds x30, x30, x0  // add C0 with P0 
    adcs x21, x21, x1  // add C1 with P1 
    stp x30, x21, [x9, #0]  // store C0 and C1 
    adcs x22, x22, x2  // add C2 with P2 
    adcs x23, x23, x3  // add C3 with P3 
    stp x22, x23, [x9, #16]  // store C2 and C3 
    adcs x24, x24, x4  // add C4 with P4 
    adcs x25, x25, x5  // add C5 with P5 
    stp x24, x25, [x9, #32]  // store C4 and C5 
    adcs x26, x26, x6  // add C6 with P6 
    adcs x27, x27, x7  // add C7 with P7 
    stp x26, x27, [x9, #48]  // store C6 and C7 
    /* restore stack */
    ldp x0, x1, [sp, #0]
    ldp x2, x19, [sp, #16]
    ldp x20, x21, [sp, #32]
    ldp x22, x23, [sp, #48]
    ldp x24, x25, [sp, #64]
    ldp x26, x27, [sp, #80]
    ldp x28, x30, [sp, #96]
    add sp, sp, #112
    ret




; fmt(fp_mul_mont_512):
;     stack_pointer_st

;     // 0
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1]

;     mul     x8, x3, x7
;     umulh   x9, x3, x7
    
;     mul     x10, x4, x7
;     umulh   x11, x4, x7
    
;     mul     x12, x5, x7
;     umulh   x13, x5, x7

;     mul     x14, x6, x7
;     umulh   x15, x6, x7

;     adds    x9, x9, x10
;     adcs    x11, x11, x12
;     adcs    x13, x13, x14

;     ldp     x3, x4, [x0, #32]
;     ldp     x5, x6, [x0, #48]

;     mul     x16, x3, x7
;     umulh   x17, x3, x7

;     mul     x30, x4, x7
;     umulh   x19, x4, x7

;     mul     x20, x5, x7
;     umulh   x21, x5, x7

;     mul     x22, x6, x7
;     umulh   x23, x6, x7

;     adcs    x15, x15, x16
;     adcs    x17, x17, x30
;     adcs    x19, x19, x20
;     adcs    x21, x21, x22
;     adc     x23, x23, xzr

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x8

;     ldr     x3, p511
;     ldr     x4, p511 + 8
;     ldr     x5, p511 + 16
;     ldr     x6, p511 + 24

;     mul     x10, x3, x28
;     umulh   x12, x3, x28

;     mul     x14, x4, x28
;     umulh   x16, x4, x28

;     mul     x30, x5, x28
;     umulh   x20, x5, x28

;     mul     x22, x6, x28
;     umulh   x24, x6, x28

;     adds    x12, x12, x14
;     adcs    x16, x16, x30
;     adcs    x20, x20, x22

;     ldr     x3, p511 + 32
;     ldr     x4, p511 + 40
;     ldr     x5, p511 + 48
;     ldr     x6, p511 + 56
    
;     mul     x25, x3, x28
;     umulh   x26, x3, x28

;     mul     x27, x4, x28
;     umulh   x14, x4, x28

;     mul     x30, x5, x28
;     umulh   x22, x5, x28 
    
;     mul     x3, x6, x28
;     umulh   x4, x6, x28 

;     adcs    x24, x24, x25
;     adcs    x26, x26, x27
;     adcs    x14, x14, x30
;     adcs    x22, x22, x3
;     adc     x4, x4, xzr

;     adds    x8, x8, x10
;     adcs    x9, x9, x12
;     adcs    x11, x11, x16
;     adcs    x13, x13, x20
;     adcs    x15, x15, x24
;     adcs    x17, x17, x26
;     adcs    x19, x19, x14
;     adcs    x21, x21, x22
;     adcs    x23, x23, x4
;     adc     x8, xzr, xzr    
    
;     // 1
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #8]

;     schoolbook_compact_registers_first

;     adds    x9, x9, x10
;     adcs    x11, x11, x12
;     adcs    x13, x13, x16
;     adcs    x15, x15, x20
;     adcs    x17, x17, x24
;     adcs    x19, x19, x26
;     adcs    x21, x21, x14
;     adcs    x23, x23, x22
;     adc     x8, x8, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x9
    
;     schoolbook_compact_registers_second

;     adds    x9, x9, x10
;     adcs    x11, x11, x12
;     adcs    x13, x13, x16
;     adcs    x15, x15, x20
;     adcs    x17, x17, x24
;     adcs    x19, x19, x26
;     adcs    x21, x21, x14
;     adcs    x23, x23, x22
;     adcs    x8, x8, x4
;     adc     x9, xzr, xzr   
    
;     // 2
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #16]

;     schoolbook_compact_registers_first

;     adds    x11, x11, x10
;     adcs    x13, x13, x12
;     adcs    x15, x15, x16
;     adcs    x17, x17, x20
;     adcs    x19, x19, x24
;     adcs    x21, x21, x26
;     adcs    x23, x23, x14
;     adcs    x8, x8, x22
;     adc     x9, x9, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x11

;     schoolbook_compact_registers_second

;     adds    x11, x11, x10
;     adcs    x13, x13, x12
;     adcs    x15, x15, x16
;     adcs    x17, x17, x20
;     adcs    x19, x19, x24
;     adcs    x21, x21, x26
;     adcs    x23, x23, x14
;     adcs    x8, x8, x22
;     adcs    x9, x9, x4
;     adc     x11, xzr, xzr  

;     // 3
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #24]

;     schoolbook_compact_registers_first

;     adds    x13, x13, x10
;     adcs    x15, x15, x12
;     adcs    x17, x17, x16
;     adcs    x19, x19, x20
;     adcs    x21, x21, x24
;     adcs    x23, x23, x26
;     adcs    x8, x8, x14
;     adcs    x9, x9, x22
;     adc     x11, x11, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x13

;     schoolbook_compact_registers_second

;     adds    x13, x13, x10
;     adcs    x15, x15, x12
;     adcs    x17, x17, x16
;     adcs    x19, x19, x20
;     adcs    x21, x21, x24
;     adcs    x23, x23, x26
;     adcs    x8, x8, x14
;     adcs    x9, x9, x22
;     adcs    x11, x11, x4
;     adc     x13, xzr, xzr   

;     // 4
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #32]

;     schoolbook_compact_registers_first

;     adds    x15, x15, x10
;     adcs    x17, x17, x12
;     adcs    x19, x19, x16
;     adcs    x21, x21, x20
;     adcs    x23, x23, x24
;     adcs    x8, x8, x26
;     adcs    x9, x9, x14
;     adcs    x11, x11, x22
;     adc     x13, x13, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x15

;     schoolbook_compact_registers_second
  
;     adds    x15, x15, x10
;     adcs    x17, x17, x12
;     adcs    x19, x19, x16
;     adcs    x21, x21, x20
;     adcs    x23, x23, x24
;     adcs    x8, x8, x26
;     adcs    x9, x9, x14
;     adcs    x11, x11, x22
;     adcs    x13, x13, x4
;     adc     x15, xzr, xzr   

;     // 5
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #40]

;     schoolbook_compact_registers_first

;     adds    x17, x17, x10
;     adcs    x19, x19, x12
;     adcs    x21, x21, x16
;     adcs    x23, x23, x20
;     adcs    x8, x8, x24
;     adcs    x9, x9, x26
;     adcs    x11, x11, x14
;     adcs    x13, x13, x22
;     adc     x15, x15, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x17

;     schoolbook_compact_registers_second 

;     adds    x17, x17, x10
;     adcs    x19, x19, x12
;     adcs    x21, x21, x16
;     adcs    x23, x23, x20
;     adcs    x8, x8, x24
;     adcs    x9, x9, x26
;     adcs    x11, x11, x14
;     adcs    x13, x13, x22
;     adcs    x15, x15, x4
;     adc     x17, xzr, xzr   

;     // 6
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #48]

;     schoolbook_compact_registers_first

;     adds    x19, x19, x10
;     adcs    x21, x21, x12
;     adcs    x23, x23, x16
;     adcs    x8, x8, x20
;     adcs    x9, x9, x24
;     adcs    x11, x11, x26
;     adcs    x13, x13, x14
;     adcs    x15, x15, x22
;     adc     x17, x17, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x19

;     schoolbook_compact_registers_second
  
;     adds    x19, x19, x10
;     adcs    x21, x21, x12
;     adcs    x23, x23, x16
;     adcs    x8, x8, x20
;     adcs    x9, x9, x24
;     adcs    x11, x11, x26
;     adcs    x13, x13, x14
;     adcs    x15, x15, x22
;     adcs    x17, x17, x4
;     adc     x19, xzr, xzr   

;     // 7
;     ldp     x3, x4, [x0]
;     ldp     x5, x6, [x0, #16]
;     ldr     x7, [x1, #56]

;     schoolbook_compact_registers_first

;     adds    x21, x21, x10
;     adcs    x23, x23, x12
;     adcs    x8, x8, x16
;     adcs    x9, x9, x20
;     adcs    x11, x11, x24
;     adcs    x13, x13, x26
;     adcs    x15, x15, x14
;     adcs    x17, x17, x22
;     adc     x19, x19, x4

;     ldr     x28, minus_p511_inverse
;     mul     x28, x28, x21

;     schoolbook_compact_registers_second

;     adds    x21, x21, x10
;     adcs    x23, x23, x12   // mc0
;     adcs    x8, x8, x16     // mc1
;     adcs    x9, x9, x20     // mc2
;     adcs    x11, x11, x24   // mc3
;     adcs    x13, x13, x26   // mc4
;     adcs    x15, x15, x14   // mc5
;     adcs    x17, x17, x22   // mc6
;     adc    x19, x19, x4     // mc7

;     ldr     x10, p511
;     ldr     x12, p511 + 8
;     ldr     x14, p511 + 16
;     ldr     x16, p511 + 24

;     ldr     x3, p511 + 32
;     ldr     x4, p511 + 40
;     ldr     x5, p511 + 48
;     ldr     x6, p511 + 56
    
;     subs    x23, x23, x10
;     sbcs    x8, x8, x12
;     sbcs    x9, x9, x14
;     sbcs    x11, x11, x16
;     sbcs    x13, x13, x3
;     sbcs    x15, x15, x4
;     sbcs    x17, x17, x5
;     sbcs    x19, x19, x6
;     sbc     x28, xzr, xzr

;     and     x10, x10, x28
;     and     x12, x12, x28
;     and     x14, x14, x28
;     and     x16, x16, x28
;     and     x3, x3, x28
;     and     x4, x4, x28
;     and     x5, x5, x28
;     and     x6, x6, x28

;     adds    x23, x23, x10
;     adcs    x8, x8, x12
;     adcs    x9, x9, x14
;     adcs    x11, x11, x16
;     adcs    x13, x13, x3
;     adcs    x15, x15, x4
;     adcs    x17, x17, x5
;     adcs    x19, x19, x6
    
;     stp     x23, x8, [x2]
;     stp     x9, x11, [x2, #16]
;     stp     x13, x15, [x2, #32]
;     stp     x17, x19, [x2, #48]

;     stack_pointer_ld

;     ret


