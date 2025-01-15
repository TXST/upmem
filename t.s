
a.out:	file format elf32-dpu


Disassembly of section .text:

80000000 <__bootstrap>:
80000000: 06 00 00 83 73 3c 00 00      	jnz id, __sys_start_thread
80000008: 00 00 00 46 e3 7c 00 00      	sd zero, 16, 0
80000010: 00 00 bc 00 e3 6b 00 00      	move r23, 203

80000018 <__sys_atomic_bit_clear>:
80000018: 06 00 8c 82 5f 3c 00 00      	jeq r23, 200, __sys_start_thread
80000020: 05 00 00 80 5f 7c 00 00      	release r23, 0, nz, 0x80000028
80000028: 03 00 ff 01 df 2f 00 00      	add r23, r23, -1, true, __sys_atomic_bit_clear

80000030 <__sys_start_thread>:
80000030: 08 00 e0 82 73 3c 00 00      	jeq id, 14, 0x80000040
80000038: 00 00 10 20 f3 7d 00 00      	boot id, 1
80000040: 00 00 05 46 7f 7b 00 00      	ld d22, id8, 80
80000048: 00 00 b0 00 e3 8b 00 00      	call r23, main

80000050 <__sys_end>:
80000050: 0a 00 00 21 f3 7e 00 00      	stop true, __sys_end

80000058 <main>:
; int main() {
80000058: 00 00 8d 46 da 7e 00 00      	sd r22, 88, d22
80000060: 00 00 06 00 5b 0b 00 00      	add r22, r22, 96
80000068: ff ff 8d 47 d9 7d 00 00      	sd r22, -72, d14
80000070: ff ff 01 47 da 7d 00 00      	sd r22, -80, d16
80000078: ff ff 85 47 5a 7d 00 00      	sd r22, -88, d18
80000080: ff ff 09 47 5a 7d 00 00      	sd r22, -96, d20
;     return __builtin_dpu_tid();
80000088: 17 00 00 b2 73 80 00 00      	move r0, id, z, 0x800000b8
;         while(finish != 1) {
80000090: 00 00 c1 40 63 70 00 00      	lbu r0, zero, 28
80000098: 77 00 10 83 03 3c 00 00      	jneq r0, 1, 0x800003b8
;         barrier_wait(&my_barrier);
800000a0: 00 80 01 00 63 60 00 00      	move r0, 272
800000a8: 00 40 d5 00 e3 8b 00 00      	call r23, barrier_wait
800000b0: 00 40 54 00 63 8c 00 00      	jump 0x80001228
;         if(init == 0){
800000b8: 00 00 81 40 63 70 00 00      	lbu r0, zero, 24
800000c0: 65 00 00 83 03 3c 00 00      	jnz r0, 0x80000328
;             int wsize = cout[conv_num] *
800000c8: 00 80 0d 44 63 70 00 00      	lw r0, zero, 464
800000d0: 00 80 e2 41 83 70 00 00      	lbs r1, r0, 302
;                         cin[conv_num] * CONV_SIZE * CONV_SIZE;
800000d8: 00 00 14 40 03 80 00 00      	lsl r0, r0, 1
800000e0: 00 80 41 43 03 71 00 00      	lhs r2, r0, 276
;             init = 1;
800000e8: 00 00 81 00 63 60 00 00      	move r0, 24
800000f0: 00 00 01 40 03 7c 00 00      	sb r0, 0, 1
;             int wsize = cout[conv_num] *
800000f8: 26 00 04 1e 04 0c 00 00      	mul_ul_ul r0, r1, r2, small, 0x80000130
80000100: 00 00 a4 00 84 0d 00 00      	mul_sh_ul r3, r1, r2
80000108: 00 00 80 40 0c 80 00 00      	lsl_add r0, r0, r3, 8
80000110: 00 00 a2 00 88 0d 00 00      	mul_sh_ul r3, r2, r1
80000118: 00 00 80 40 0c 80 00 00      	lsl_add r0, r0, r3, 8
80000120: 00 00 74 00 84 0c 00 00      	mul_sh_sh r1, r1, r2
80000128: 00 00 00 50 04 80 00 00      	lsl_add r0, r0, r1, 16
;                         cin[conv_num] * CONV_SIZE * CONV_SIZE;
80000130: 00 00 30 40 00 87 00 00      	lsl_add r14, r0, r0, 3
;             buffer_weight = mem_alloc(wsize);
80000138: 00 00 00 b0 3b 80 00 00      	move r0, r14
80000140: 00 40 65 00 e3 8b 00 00      	call r23, mem_alloc
;             osize = cout[conv_num] *
80000148: 00 80 0d 44 e3 70 00 00      	lw r1, zero, 464
80000150: 00 80 e2 41 07 71 00 00      	lbs r2, r1, 302
;                     out_HW[conv_num] * out_HW[conv_num];
80000158: 00 00 14 40 87 80 00 00      	lsl r1, r1, 1
80000160: 00 80 c3 43 87 70 00 00      	lhs r1, r1, 316
;             buffer_weight = mem_alloc(wsize);
80000168: 00 00 80 44 60 7d 00 00      	sw zero, 40, r0
;             osize = cout[conv_num] *
80000170: 35 00 04 1e 04 0c 00 00      	mul_ul_ul r0, r1, r2, small, 0x800001a8
80000178: 00 00 a4 00 84 0d 00 00      	mul_sh_ul r3, r1, r2
80000180: 00 00 80 40 0c 80 00 00      	lsl_add r0, r0, r3, 8
80000188: 00 00 a2 00 88 0d 00 00      	mul_sh_ul r3, r2, r1
80000190: 00 00 80 40 0c 80 00 00      	lsl_add r0, r0, r3, 8
80000198: 00 00 74 00 04 0d 00 00      	mul_sh_sh r2, r1, r2
800001a0: 00 00 00 50 08 80 00 00      	lsl_add r0, r0, r2, 16
;                     out_HW[conv_num] * out_HW[conv_num];
800001a8: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
;             osize = cout[conv_num] *
800001b0: 00 00 c0 44 60 7d 00 00      	sw zero, 44, r0
;             buffer_out = mem_alloc(osize);
800001b8: 00 40 65 00 e3 8b 00 00      	call r23, mem_alloc
;             int isize = TASK_NUM * out_HW[conv_num] * input_groups[conv_num];
800001c0: 00 80 0d 44 63 71 00 00      	lw r2, zero, 464
800001c8: 00 00 14 40 8b 80 00 00      	lsl r1, r2, 1
800001d0: 00 80 c3 43 87 70 00 00      	lhs r1, r1, 316
800001d8: 00 80 36 41 0b 71 00 00      	lbs r2, r2, 355
;             buffer_out = mem_alloc(osize);
800001e0: 00 00 00 44 e0 7d 00 00      	sw zero, 48, r0
;             int isize = TASK_NUM * out_HW[conv_num] * input_groups[conv_num];
800001e8: 44 00 04 1e 04 0c 00 00      	mul_ul_ul r0, r1, r2, small, 0x80000220
800001f0: 00 00 a4 00 84 0d 00 00      	mul_sh_ul r3, r1, r2
800001f8: 00 00 80 40 0c 80 00 00      	lsl_add r0, r0, r3, 8
80000200: 00 00 a2 00 88 0d 00 00      	mul_sh_ul r3, r2, r1
80000208: 00 00 80 40 0c 80 00 00      	lsl_add r0, r0, r3, 8
80000210: 00 00 74 00 84 0c 00 00      	mul_sh_sh r1, r1, r2
80000218: 00 00 00 50 04 80 00 00      	lsl_add r0, r0, r1, 16
80000220: 00 00 44 40 83 80 00 00      	lsl r1, r0, 4
80000228: 00 00 12 60 80 87 00 00      	lsl_sub r15, r1, r0, 1
;             buffer_inA = mem_alloc(isize);
80000230: 00 00 00 b0 3f 80 00 00      	move r0, r15
80000238: 00 40 65 00 e3 8b 00 00      	call r23, mem_alloc
80000240: 00 00 80 44 e0 7d 00 00      	sw zero, 56, r0
;             buffer_inB = mem_alloc(isize);
80000248: 00 00 00 b0 3f 80 00 00      	move r0, r15
80000250: 00 40 65 00 e3 8b 00 00      	call r23, mem_alloc
80000258: 00 00 00 44 60 7e 00 00      	sw zero, 64, r0
;             if(wsize % 2048) mram_read(weight + offset, buffer_weight + offset, (wsize % 2048));
80000260: 00 00 f8 50 3b 80 00 00      	asr r0, r14, 31
80000268: 00 00 5c 30 01 81 00 00      	lsr_add r2, r14, r0, 21
80000270: ff 1f 00 ff 0b 50 00 00      	and r0, r2, -2048
80000278: 00 00 c0 80 38 0c 00 00      	sub r0, r14, r0
80000280: 00 10 00 00 e3 61 00 00      	move r3, 2048
80000288: 00 00 00 00 e3 60 00 00      	move r1, 0
;             for(int i = 0;i < (wsize / 2048);i ++,offset += 2048){
80000290: 5c 00 c6 96 38 3c 00 00      	jlts r14, r3, 0x800002e0
80000298: 00 00 b8 40 0b 81 00 00      	asr r2, r2, 11
800002a0: 00 00 00 00 e3 60 00 00      	move r1, 0
;                 mram_read(weight + offset, buffer_weight + offset, 2048);
800002a8: 00 00 82 44 e3 71 00 00      	lw r3, zero, 40
800002b0: 00 00 00 00 63 62 00 00      	move r4, 0
800002b8: 00 00 c2 00 10 0e 00 00      	add r4, r4, r1
;     __builtin_dpu_ldma(to, from, nb_of_bytes);
800002c0: 00 00 c2 00 8c 0d 00 00      	add r3, r3, r1
800002c8: 00 00 08 ff 0c 70 00 00      	ldma r3, r4, 255
;             for(int i = 0;i < (wsize / 2048);i ++,offset += 2048){
800002d0: 00 10 00 00 87 00 00 00      	add r1, r1, 2048
800002d8: 55 00 ff 03 0b 0d 00 00      	add r2, r2, -1, nz, 0x800002a8
;             if(wsize % 2048) mram_read(weight + offset, buffer_weight + offset, (wsize % 2048));
800002e0: 65 00 00 82 03 3c 00 00      	jz r0, 0x80000328
800002e8: 00 00 82 44 63 71 00 00      	lw r2, zero, 40
800002f0: 00 00 00 00 e3 61 00 00      	move r3, 0
800002f8: 00 00 c2 00 8c 0d 00 00      	add r3, r3, r1
80000300: 00 00 c2 00 88 0c 00 00      	add r1, r2, r1
80000308: ff ff ff ff 63 61 00 00      	move r2, -1
;     __builtin_dpu_ldma(to, from, nb_of_bytes);
80000310: 00 00 34 20 00 80 00 00      	lsr_add r0, r2, r0, 3
80000318: 00 00 82 50 00 80 00 00      	lsl_add r0, r1, r0, 24
80000320: 00 00 06 00 00 70 00 00      	ldma r0, r3, 0
;         for(int i = 0;i < osize;i ++){
80000328: 00 00 c2 44 63 70 00 00      	lw r0, zero, 44
80000330: 6e 00 10 96 03 3c 00 00      	jlts r0, 1, 0x80000370
80000338: 00 00 00 00 63 60 00 00      	move r0, 0
;             buffer_out[i] = 0;
80000340: 00 00 03 44 e3 70 00 00      	lw r1, zero, 48
80000348: 00 00 c0 00 84 0c 00 00      	add r1, r1, r0
80000350: 00 00 00 40 07 7c 00 00      	sb r1, 0, 0
;         for(int i = 0;i < osize;i ++){
80000358: 00 00 c2 44 e3 70 00 00      	lw r1, zero, 44
80000360: 00 00 10 00 03 00 00 00      	add r0, r0, 1
80000368: 68 00 c2 96 00 3c 00 00      	jlts r0, r1, 0x80000340
;         if(pid % 2){
80000370: 00 80 8d 46 63 70 00 00      	ld d0, zero, 472
80000378: 00 00 10 00 87 50 00 00      	and r1, r1, 1
80000380: 00 00 00 00 03 50 00 00      	and r0, r0, 0
80000388: 00 00 00 00 eb 51 00 00      	move.s d2, 0
80000390: 74 00 c6 83 04 3c 00 00      	jneq r1, r3, 0x800003a0
80000398: 94 01 c4 82 00 3c 00 00      	jeq r0, r2, 0x80000ca0
800003a0: 44 23 00 00 63 60 00 00      	move r0, 3425280
800003a8: 24 20 00 00 e3 60 00 00      	move r1, 148480
800003b0: 00 80 69 00 63 8c 00 00      	jump 0x80000cb0
;         int16_t cin_ = 0,wsize_cout = cin[conv_num] * 9;  //每个输出通道的weight数量
800003b8: 00 80 0d 44 63 70 00 00      	lw r0, zero, 464
800003c0: 00 00 14 40 03 80 00 00      	lsl r0, r0, 1
800003c8: 00 80 41 43 03 70 00 00      	lhs r0, r0, 276
800003d0: 00 00 30 40 00 80 00 00      	lsl_add r0, r0, r0, 3
800003d8: 00 00 00 00 e3 60 00 00      	move r1, 0
800003e0: 00 00 70 30 03 80 00 00      	extsh r0, r0
800003e8: ff ff 40 45 d8 7e 00 00      	sw r22, -44, r0
800003f0: 00 00 00 b0 87 87 00 00      	move r15, r1
800003f8: ff ff 02 45 d8 7f 00 00      	sw r22, -16, r1
80000400: 83 00 00 b1 07 89 00 00      	move r18, r1, true, 0x80000418
;         while(finish != 1) {
80000408: 00 00 c1 40 63 70 00 00      	lbu r0, zero, 28
80000410: 14 00 10 82 03 3c 00 00      	jeq r0, 1, 0x800000a0
;             barrier_wait(&my_barrier);
80000418: 00 80 01 00 63 60 00 00      	move r0, 272
80000420: 00 40 d5 00 e3 8b 00 00      	call r23, barrier_wait
;     __asm__ volatile("acquire %[mtx], 0, nz, ." : : [mtx] "r"(mutex) :);
80000428: 00 00 8c 00 63 60 00 00      	move r0, 200
80000430: 86 00 00 83 03 7c 00 00      	acquire r0, 0, nz, 0x80000430
;             T myline = line[ztb];
80000438: 00 00 02 41 e3 70 00 00      	lbs r1, zero, 32
;             ztb ++;
80000440: 00 00 10 00 87 01 00 00      	add r3, r1, 1
;             if(ztb == 14) ztb = 0;
80000448: ff ff 0f 44 5b 71 00 00      	lw r2, r22, -16
80000450: 00 00 ff 00 0f 52 00 00      	and r4, r3, 255
80000458: 8d 00 e0 82 13 3c 00 00      	jeq r4, 14, 0x80000468
80000460: 00 00 00 b0 0f 81 00 00      	move r2, r3
80000468: 00 80 4a 41 87 70 00 00      	lbs r1, r1, 420
80000470: 00 00 04 40 60 7d 00 00      	sb zero, 32, r2
;     __asm__ volatile("release %[mtx], 0, nz, .+1" : : [mtx] "r"(mutex) :);
80000478: 90 00 00 80 03 7c 00 00      	release r0, 0, nz, 0x80000480
;             for(T b = 0;b < input_groups[conv_num];b ++){
80000480: 00 80 0d 46 63 78 00 00      	ld d16, zero, 464
80000488: 00 80 36 41 47 70 00 00      	lbs r0, r17, 355
80000490: 81 00 10 96 03 3c 00 00      	jlts r0, 1, 0x80000408
80000498: 00 00 00 00 63 60 00 00      	move r0, 0
800004a0: ff ff ff ff 87 00 00 00      	add r1, r1, -1
800004a8: ff ff 82 45 58 7f 00 00      	sw r22, -24, r1
800004b0: ff ff c0 45 58 7f 00 00      	sw r22, -20, r0
800004b8: 9f 00 00 b1 03 8a 00 00      	move r20, r0, true, 0x800004f8
;             for(T b = 0;b < input_groups[conv_num];b ++){
800004c0: 00 80 36 41 47 71 00 00      	lbs r2, r17, 355
;                 if(cin_ == cin[conv_num]){
800004c8: 00 00 c0 86 04 0c 00 00      	sub r0, r1, r0, z
800004d0: ff ff 4e 44 5b 7a 00 00      	lw r20, r22, -28
;             for(T b = 0;b < input_groups[conv_num];b ++){
800004d8: 00 00 10 00 53 0a 00 00      	add r20, r20, 1
800004e0: ff ff cd 44 db 77 00 00      	lw r15, r22, -36
;                 if(cin_ == cin[conv_num]){
800004e8: 00 00 c0 00 bc 1f 00 00      	add r15, r15, r0
;             for(T b = 0;b < input_groups[conv_num];b ++){
800004f0: 81 00 c4 97 50 3c 00 00      	jges r20, r2, 0x80000408
;                 T* in = buffer_in + (b * TASK_NUM + myline - 1) * PAD(out_HW[conv_num]);
800004f8: 00 00 c4 44 63 77 00 00      	lw r14, zero, 76
80000500: 00 00 14 40 47 80 00 00      	lsl r0, r17, 1
80000508: 00 80 c3 43 83 70 00 00      	lhs r1, r0, 316
80000510: 00 00 44 40 53 80 00 00      	lsl r0, r20, 4
80000518: 00 00 10 60 50 80 00 00      	lsl_sub r0, r0, r20, 1
80000520: ff ff 8e 44 db 79 00 00      	lw r19, r22, -24
80000528: 00 00 c0 00 4c 0c 00 00      	add r0, r19, r0
80000530: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
;                 if(myline - 1 == 13 && groups == output_groups[conv_num] - 1) last = 1;
80000538: ae 00 d0 83 4f 3c 00 00      	jneq r19, 13, 0x80000570
80000540: 00 80 65 41 c7 70 00 00      	lbs r1, r17, 342
80000548: 00 00 50 30 3f 81 00 00      	extsb r2, r15
80000550: ff ff ff ff 87 00 00 00      	add r1, r1, -1
80000558: 00 00 00 00 e3 61 00 00      	move r3, 0
80000560: ff ff 86 45 58 7e 00 00      	sw r22, -56, r3
80000568: b0 00 c4 82 04 3c 00 00      	jeq r1, r2, 0x80000580
80000570: 00 00 10 00 e3 60 00 00      	move r1, 1
80000578: ff ff 82 45 58 7e 00 00      	sw r22, -56, r1
80000580: ff ff 48 45 5a 7f 00 00      	sw r22, -28, r20
;                 for(int16_t i = 0;i < out_HW[conv_num];i += 2){
80000588: 00 00 14 40 c7 80 00 00      	lsl r1, r17, 1
80000590: 00 80 c3 43 87 70 00 00      	lhs r1, r1, 316
80000598: ff ff ce 45 d9 7e 00 00      	sw r22, -36, r15
800005a0: ff ff 04 45 5a 7f 00 00      	sw r22, -32, r18
800005a8: 8c 01 10 96 07 3c 00 00      	jlts r1, 1, 0x80000c60
800005b0: 00 00 ff 00 bf 50 00 00      	and r1, r15, 255
800005b8: ff ff 8e 44 db 71 00 00      	lw r3, r22, -24
800005c0: 00 00 b2 c0 8c 80 00 00      	or r1, r3, r1
800005c8: 00 00 c0 00 b8 2e 00 00      	add r21, r14, r0
800005d0: ff ff ce 44 5b 70 00 00      	lw r0, r22, -20
800005d8: 00 00 c0 87 04 0c 00 00      	sub r0, r1, r0, nz
800005e0: ff ff c0 45 58 7e 00 00      	sw r22, -52, r0
800005e8: 00 00 70 30 4b 80 00 00      	extsh r0, r18
800005f0: 00 00 30 40 00 80 00 00      	lsl_add r0, r0, r0, 3
800005f8: 00 00 50 30 bf 80 00 00      	extsb r1, r15
80000600: 00 00 44 40 07 81 00 00      	lsl r2, r1, 4
80000608: 00 00 14 60 84 80 00 00      	lsl_sub r1, r2, r1, 1
80000610: 00 00 c2 00 8c 0c 00 00      	add r1, r3, r1
80000618: ff ff 02 45 d8 7e 00 00      	sw r22, -48, r1
80000620: 00 00 00 00 e3 65 00 00      	move r11, 0
;                 for(int16_t i = 0;i < out_HW[conv_num];i += 2){
80000628: 00 00 80 00 03 00 00 00      	add r0, r0, 8
80000630: ff ff 80 45 d8 7e 00 00      	sw r22, -40, r0
80000638: ce 00 00 b1 2f 8a 00 00      	move r20, r11, true, 0x80000670
80000640: 00 00 14 40 47 80 00 00      	lsl r0, r17, 1
80000648: 00 80 c3 43 03 70 00 00      	lhs r0, r0, 316
80000650: 20 00 00 00 e3 60 00 00      	move r1, 131072
80000658: 00 00 02 50 2c 8a 00 00      	lsl_add r20, r1, r11, 16
80000660: 00 00 08 50 d3 85 00 00      	asr r11, r20, 16
80000668: 8c 01 c0 97 2c 3c 00 00      	jges r11, r0, 0x80000c60
;                     for(T j = 0;j < cout[conv_num];j ++){
80000670: 00 80 e2 41 47 70 00 00      	lbs r0, r17, 302
80000678: c8 00 10 96 03 3c 00 00      	jlts r0, 1, 0x80000640
80000680: 00 00 10 00 af 07 00 00      	add r15, r11, 1
80000688: 00 00 00 00 e3 66 00 00      	move r13, 0
80000690: ff ff 8d 44 db 79 00 00      	lw r19, r22, -40
80000698: 00 00 fd 00 63 8c 00 00      	jump 0x800006f8
800006a0: 00 00 c2 80 bc 0c 00 00      	sub r1, r15, r1
800006a8: 00 00 c2 00 00 0c 00 00      	add r0, r0, r1
800006b0: 00 00 00 41 83 70 00 00      	lbs r1, r0, 0
800006b8: 00 00 c2 00 88 0c 00 00      	add r1, r2, r1
800006c0: 00 00 02 40 00 7c 00 00      	sb r0, 0, r1
;                     for(T j = 0;j < cout[conv_num];j ++){
800006c8: 00 80 0d 46 63 78 00 00      	ld d16, zero, 464
800006d0: 00 80 e2 41 47 70 00 00      	lbs r0, r17, 302
800006d8: 00 00 10 00 b7 06 00 00      	add r13, r13, 1
800006e0: ff ff 4d 44 db 70 00 00      	lw r1, r22, -44
800006e8: 00 00 c2 00 cc 2d 00 00      	add r19, r19, r1
800006f0: c8 00 c0 97 34 3c 00 00      	jges r13, r0, 0x80000640
;                         T* wei = buffer_weight + j * wsize_cout + cin_ * 9;
800006f8: 00 00 82 44 63 70 00 00      	lw r0, zero, 40
80000700: ff ff 00 45 58 7e 00 00      	sw r22, -64, r0
;                         T* out = buffer_out + j * output_HXW[conv_num] + (groups * TASK_NUM + myline - 1) * out_HW[conv_num];
80000708: 00 00 24 40 47 80 00 00      	lsl r0, r17, 2
80000710: 00 80 07 44 03 70 00 00      	lw r0, r0, 368
80000718: 00 00 03 44 63 79 00 00      	lw r18, zero, 48
80000720: ff ff 4a 45 59 7e 00 00      	sw r22, -60, r13
80000728: 00 00 00 b0 b7 80 00 00      	move r1, r13
80000730: 00 00 00 b0 2f 87 00 00      	move r14, r11
80000738: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
80000740: 00 00 14 40 c7 80 00 00      	lsl r1, r17, 1
80000748: 00 80 c3 43 07 78 00 00      	lhs r16, r1, 316
80000750: 00 00 c0 00 c8 2c 00 00      	add r17, r18, r0
80000758: ff ff 0d 44 5b 70 00 00      	lw r0, r22, -48
80000760: 00 00 00 b0 c3 80 00 00      	move r1, r16
80000768: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
80000770: 00 00 00 b0 bb 85 00 00      	move r11, r14
;                         T* out = buffer_out + j * output_HXW[conv_num] + (groups * TASK_NUM + myline - 1) * out_HW[conv_num];
80000778: 00 00 c0 00 44 0c 00 00      	add r0, r17, r0
;                         if(!last){
80000780: ff ff 8c 44 db 70 00 00      	lw r1, r22, -56
80000788: 26 01 00 82 07 3c 00 00      	jz r1, 0x80000930
80000790: 02 01 00 82 53 3c 00 00      	jz r20, 0x80000810
80000798: ff ff 0c 44 db 73 00 00      	lw r7, r22, -64
;                                 out[i + out_HW[conv_num]] += (wei[0] * in[i - 1]
800007a0: 00 00 c6 00 9e 0c 00 00      	add r1, r7, r19
800007a8: ff ff 8f 41 07 71 00 00      	lbs r2, r1, -8
800007b0: 00 00 c6 00 d5 0d 00 00      	add r3, r21, r11
800007b8: ff ff ff 41 0f 72 00 00      	lbs r4, r3, -1
;                                                               + wei[1] * in[i]
800007c0: ff ff 9f 41 87 72 00 00      	lbs r5, r1, -7
800007c8: 00 00 00 41 0f 73 00 00      	lbs r6, r3, 0
;                                                               + wei[2] * in[i + 1]);
800007d0: ff ff af 41 87 70 00 00      	lbs r1, r1, -6
800007d8: 00 00 10 41 8f 71 00 00      	lbs r3, r3, 1
;                                 out[i + out_HW[conv_num]] += (wei[0] * in[i - 1]
800007e0: 00 00 44 00 10 0d 00 00      	mul_sl_sl r2, r4, r2
;                                                               + wei[1] * in[i]
800007e8: 00 00 4a 00 18 0e 00 00      	mul_sl_sl r4, r6, r5
800007f0: 00 00 c4 00 10 0d 00 00      	add r2, r4, r2
;                                                               + wei[2] * in[i + 1]);
800007f8: 00 00 42 00 8c 0c 00 00      	mul_sl_sl r1, r3, r1
80000800: 00 00 c2 00 88 0c 00 00      	add r1, r2, r1
;                                 out[i + out_HW[conv_num]] += (wei[0] * in[i - 1]
80000808: 0b 01 c0 01 2e 2c 00 00      	add r16, r11, r16, true, 0x80000858
80000810: ff ff 0c 44 db 73 00 00      	lw r7, r22, -64
;                                 out[i + out_HW[conv_num]] += (wei[1] * in[i]
80000818: 00 00 c6 00 9e 0c 00 00      	add r1, r7, r19
80000820: ff ff 9f 41 07 71 00 00      	lbs r2, r1, -7
80000828: 00 00 00 41 d7 71 00 00      	lbs r3, r21, 0
;                                                               + wei[2] * in[i + 1]);
80000830: ff ff af 41 87 70 00 00      	lbs r1, r1, -6
80000838: 00 00 10 41 57 72 00 00      	lbs r4, r21, 1
;                                 out[i + out_HW[conv_num]] += (wei[1] * in[i]
80000840: 00 00 44 00 0c 0d 00 00      	mul_sl_sl r2, r3, r2
;                                                               + wei[2] * in[i + 1]);
80000848: 00 00 42 00 90 0c 00 00      	mul_sl_sl r1, r4, r1
80000850: 00 00 c4 00 84 0c 00 00      	add r1, r1, r2
80000858: 00 00 c0 00 02 0d 00 00      	add r2, r0, r16
80000860: 00 00 00 41 8b 71 00 00      	lbs r3, r2, 0
80000868: 00 00 c6 00 84 0c 00 00      	add r1, r1, r3
80000870: 00 00 02 40 08 7c 00 00      	sb r2, 0, r1
;                             if(i == out_HW[conv_num] - 1){
80000878: 00 80 0d 44 e3 70 00 00      	lw r1, zero, 464
80000880: 00 00 14 40 87 80 00 00      	lsl r1, r1, 1
80000888: 00 80 c3 43 87 70 00 00      	lhs r1, r1, 316
80000890: 00 00 c6 00 9e 0d 00 00      	add r3, r7, r19
80000898: ff ff 8f 41 0f 71 00 00      	lbs r2, r3, -8
800008a0: 00 00 c6 00 55 0e 00 00      	add r4, r21, r11
800008a8: 00 00 00 41 93 72 00 00      	lbs r5, r4, 0
800008b0: ff ff 9f 41 0f 73 00 00      	lbs r6, r3, -7
800008b8: 00 00 10 41 93 73 00 00      	lbs r7, r4, 1
;                             if(i == out_HW[conv_num] - 1){
800008c0: ff ff ff ff 07 04 00 00      	add r8, r1, -1
800008c8: 00 00 44 00 14 0d 00 00      	mul_sl_sl r2, r5, r2
800008d0: 00 00 4c 00 9c 0e 00 00      	mul_sl_sl r5, r7, r6
800008d8: 00 00 c4 00 14 0d 00 00      	add r2, r5, r2
;                             if(i == out_HW[conv_num] - 1){
800008e0: 21 01 c0 82 2d 3c 00 00      	jeq r11, r8, 0x80000908
;                                                                   + wei[2] * in[i + 2]);
800008e8: ff ff af 41 8f 71 00 00      	lbs r3, r3, -6
800008f0: 00 00 20 41 13 72 00 00      	lbs r4, r4, 2
800008f8: 00 00 46 00 90 0d 00 00      	mul_sl_sl r3, r4, r3
80000900: 00 00 c6 00 08 0d 00 00      	add r2, r2, r3
80000908: 00 00 c2 00 bc 0c 00 00      	add r1, r15, r1
80000910: 00 00 c2 00 80 0c 00 00      	add r1, r0, r1
80000918: 00 00 00 41 87 71 00 00      	lbs r3, r1, 0
80000920: 00 00 c6 00 08 0d 00 00      	add r2, r2, r3
80000928: 00 00 04 40 04 7c 00 00      	sb r1, 0, r2
;                         if(i == 0){
80000930: 36 01 00 82 53 3c 00 00      	jz r20, 0x800009b0
80000938: ff ff 0c 44 5b 77 00 00      	lw r14, r22, -64
;                             out[i] +=        (wei[3] * in[i - 1]
80000940: 00 00 c6 00 ba 0c 00 00      	add r1, r14, r19
80000948: ff ff bf 41 07 71 00 00      	lbs r2, r1, -5
80000950: 00 00 c6 00 d5 0d 00 00      	add r3, r21, r11
80000958: ff ff ff 41 0f 72 00 00      	lbs r4, r3, -1
;                                               + wei[4] * in[i]
80000960: ff ff cf 41 87 72 00 00      	lbs r5, r1, -4
80000968: 00 00 00 41 0f 73 00 00      	lbs r6, r3, 0
;                                               + wei[5] * in[i + 1]);
80000970: ff ff df 41 87 70 00 00      	lbs r1, r1, -3
80000978: 00 00 10 41 8f 71 00 00      	lbs r3, r3, 1
;                             out[i] +=        (wei[3] * in[i - 1]
80000980: 00 00 44 00 10 0d 00 00      	mul_sl_sl r2, r4, r2
;                                               + wei[4] * in[i]
80000988: 00 00 4a 00 18 0e 00 00      	mul_sl_sl r4, r6, r5
80000990: 00 00 c4 00 10 0d 00 00      	add r2, r4, r2
;                                               + wei[5] * in[i + 1]);
80000998: 00 00 42 00 8c 0c 00 00      	mul_sl_sl r1, r3, r1
800009a0: 00 00 c2 00 88 0c 00 00      	add r1, r2, r1
;                             out[i] +=        (wei[3] * in[i - 1]
800009a8: 40 01 c6 01 01 0d 00 00      	add r2, r0, r11, true, 0x80000a00
800009b0: ff ff 0c 44 5b 77 00 00      	lw r14, r22, -64
;                             out[i] +=        (wei[4] * in[i]
800009b8: 00 00 c6 00 ba 0c 00 00      	add r1, r14, r19
800009c0: ff ff cf 41 07 71 00 00      	lbs r2, r1, -4
800009c8: 00 00 00 41 d7 71 00 00      	lbs r3, r21, 0
;                                               + wei[5] * in[i + 1]);
800009d0: ff ff df 41 87 70 00 00      	lbs r1, r1, -3
800009d8: 00 00 10 41 57 72 00 00      	lbs r4, r21, 1
;                             out[i] +=        (wei[4] * in[i]
800009e0: 00 00 44 00 0c 0d 00 00      	mul_sl_sl r2, r3, r2
;                                               + wei[5] * in[i + 1]);
800009e8: 00 00 42 00 90 0c 00 00      	mul_sl_sl r1, r4, r1
800009f0: 00 00 c4 00 84 0c 00 00      	add r1, r1, r2
800009f8: 00 00 00 b0 03 81 00 00      	move r2, r0
80000a00: ff ff 4c 44 db 76 00 00      	lw r13, r22, -60
80000a08: 00 00 00 41 8b 71 00 00      	lbs r3, r2, 0
80000a10: 00 00 c6 00 84 0c 00 00      	add r1, r1, r3
80000a18: 00 00 02 40 08 7c 00 00      	sb r2, 0, r1
;                         if(i == out_HW[conv_num] - 1){
80000a20: 00 80 0d 44 e3 70 00 00      	lw r1, zero, 464
80000a28: 00 00 14 40 87 80 00 00      	lsl r1, r1, 1
80000a30: 00 80 c3 43 87 70 00 00      	lhs r1, r1, 316
80000a38: 00 00 c6 00 3a 0d 00 00      	add r2, r14, r19
80000a40: ff ff bf 41 0b 72 00 00      	lbs r4, r2, -5
80000a48: 00 00 c6 00 d5 0d 00 00      	add r3, r21, r11
80000a50: 00 00 00 41 8f 72 00 00      	lbs r5, r3, 0
80000a58: ff ff cf 41 0b 73 00 00      	lbs r6, r2, -4
80000a60: 00 00 10 41 8f 73 00 00      	lbs r7, r3, 1
;                         if(i == out_HW[conv_num] - 1){
80000a68: ff ff ff ff 07 04 00 00      	add r8, r1, -1
80000a70: 00 00 48 00 94 0c 00 00      	mul_sl_sl r1, r5, r4
80000a78: 00 00 4c 00 1c 0e 00 00      	mul_sl_sl r4, r7, r6
80000a80: 00 00 c2 00 90 0c 00 00      	add r1, r4, r1
;                         if(i == out_HW[conv_num] - 1){
80000a88: 56 01 c0 82 2d 3c 00 00      	jeq r11, r8, 0x80000ab0
;                                               + wei[5] * in[i + 2]);
80000a90: ff ff df 41 0b 71 00 00      	lbs r2, r2, -3
80000a98: 00 00 20 41 8f 71 00 00      	lbs r3, r3, 2
80000aa0: 00 00 44 00 0c 0d 00 00      	mul_sl_sl r2, r3, r2
80000aa8: 00 00 c4 00 84 0c 00 00      	add r1, r1, r2
80000ab0: 00 00 ce 00 01 0d 00 00      	add r2, r0, r15
80000ab8: 00 00 00 41 8b 71 00 00      	lbs r3, r2, 0
80000ac0: 00 00 c6 00 84 0c 00 00      	add r1, r1, r3
80000ac8: 00 00 02 40 08 7c 00 00      	sb r2, 0, r1
;                         if(!first){
80000ad0: ff ff cc 44 db 70 00 00      	lw r1, r22, -52
80000ad8: d9 00 10 a2 87 80 00 00      	and r1, r1, 1, z, 0x800006c8
;                                 out[i - out_HW[conv_num]] += (wei[6] * in[i - 1]
80000ae0: 00 00 c6 00 ba 0c 00 00      	add r1, r14, r19
;                             if(i == 0){
80000ae8: 6a 01 00 82 53 3c 00 00      	jz r20, 0x80000b50
;                                 out[i - out_HW[conv_num]] += (wei[6] * in[i - 1]
80000af0: ff ff ef 41 07 71 00 00      	lbs r2, r1, -2
80000af8: 00 00 c6 00 d5 0d 00 00      	add r3, r21, r11
80000b00: ff ff ff 41 0f 72 00 00      	lbs r4, r3, -1
;                                                               + wei[7] * in[i]
80000b08: ff ff ff 41 87 72 00 00      	lbs r5, r1, -1
80000b10: 00 00 00 41 0f 73 00 00      	lbs r6, r3, 0
;                                                               + wei[8] * in[i + 1]);
80000b18: 00 00 00 41 87 70 00 00      	lbs r1, r1, 0
80000b20: 00 00 10 41 8f 71 00 00      	lbs r3, r3, 1
;                                 out[i - out_HW[conv_num]] += (wei[6] * in[i - 1]
80000b28: 00 00 44 00 10 0d 00 00      	mul_sl_sl r2, r4, r2
;                                                               + wei[7] * in[i]
80000b30: 00 00 4a 00 18 0e 00 00      	mul_sl_sl r4, r6, r5
80000b38: 00 00 c4 00 10 0d 00 00      	add r2, r4, r2
;                                                               + wei[8] * in[i + 1]);
80000b40: 00 00 42 00 8c 0c 00 00      	mul_sl_sl r1, r3, r1
80000b48: 71 01 00 b1 af 81 00 00      	move r3, r11, true, 0x80000b88
;                                 out[i - out_HW[conv_num]] += (wei[7] * in[i]
80000b50: ff ff ff 41 07 71 00 00      	lbs r2, r1, -1
80000b58: 00 00 00 41 d7 71 00 00      	lbs r3, r21, 0
;                                                               + wei[8] * in[i + 1]);
80000b60: 00 00 00 41 07 72 00 00      	lbs r4, r1, 0
80000b68: 00 00 10 41 d7 72 00 00      	lbs r5, r21, 1
;                                 out[i - out_HW[conv_num]] += (wei[7] * in[i]
80000b70: 00 00 44 00 8c 0c 00 00      	mul_sl_sl r1, r3, r2
;                                                               + wei[8] * in[i + 1]);
80000b78: 00 00 48 00 14 0d 00 00      	mul_sl_sl r2, r5, r4
80000b80: 00 00 00 00 e3 61 00 00      	move r3, 0
80000b88: 00 80 0d 44 63 72 00 00      	lw r4, zero, 464
80000b90: 00 00 14 40 13 82 00 00      	lsl r4, r4, 1
80000b98: 00 80 c3 43 13 72 00 00      	lhs r4, r4, 316
80000ba0: 00 00 c8 80 8c 0d 00 00      	sub r3, r3, r4
80000ba8: 00 00 c6 00 80 0d 00 00      	add r3, r0, r3
80000bb0: 00 00 00 41 0f 72 00 00      	lbs r4, r3, 0
80000bb8: 00 00 c2 00 88 0c 00 00      	add r1, r2, r1
80000bc0: 00 00 c8 00 84 0c 00 00      	add r1, r1, r4
80000bc8: 00 00 02 40 0c 7c 00 00      	sb r3, 0, r1
;                             if(i == out_HW[conv_num] - 1){
80000bd0: 00 80 0d 44 e3 70 00 00      	lw r1, zero, 464
80000bd8: 00 00 14 40 87 80 00 00      	lsl r1, r1, 1
80000be0: 00 80 c3 43 87 70 00 00      	lhs r1, r1, 316
80000be8: 00 00 c6 00 ba 0d 00 00      	add r3, r14, r19
80000bf0: ff ff ef 41 0f 71 00 00      	lbs r2, r3, -2
80000bf8: 00 00 c6 00 55 0e 00 00      	add r4, r21, r11
80000c00: 00 00 00 41 93 72 00 00      	lbs r5, r4, 0
80000c08: ff ff ff 41 0f 73 00 00      	lbs r6, r3, -1
80000c10: 00 00 10 41 93 73 00 00      	lbs r7, r4, 1
;                             if(i == out_HW[conv_num] - 1){
80000c18: ff ff ff ff 07 04 00 00      	add r8, r1, -1
80000c20: 00 00 44 00 14 0d 00 00      	mul_sl_sl r2, r5, r2
80000c28: 00 00 4c 00 9c 0e 00 00      	mul_sl_sl r5, r7, r6
80000c30: 00 00 c4 00 14 0d 00 00      	add r2, r5, r2
;                             if(i == out_HW[conv_num] - 1){
80000c38: d4 00 c0 82 2d 3c 00 00      	jeq r11, r8, 0x800006a0
;                                                                   + wei[8] * in[i + 2]);
80000c40: 00 00 00 41 8f 71 00 00      	lbs r3, r3, 0
80000c48: 00 00 20 41 13 72 00 00      	lbs r4, r4, 2
80000c50: 00 00 46 00 90 0d 00 00      	mul_sl_sl r3, r4, r3
80000c58: d4 00 c6 01 08 0d 00 00      	add r2, r2, r3, true, 0x800006a0
;                 if(cin_ == cin[conv_num]){
80000c60: 00 00 14 40 47 80 00 00      	lsl r0, r17, 1
80000c68: 00 80 41 42 03 70 00 00      	lhu r0, r0, 276
;                 cin_ ++;
80000c70: ff ff 0e 44 db 70 00 00      	lw r1, r22, -32
80000c78: 00 00 10 00 07 01 00 00      	add r2, r1, 1
80000c80: 0f f0 ff 00 8b 50 00 00      	and r1, r2, 65535
80000c88: 00 00 00 00 63 69 00 00      	move r18, 0
;                 if(cin_ == cin[conv_num]){
80000c90: 98 00 c0 82 04 3c 00 00      	jeq r1, r0, 0x800004c0
80000c98: 98 00 00 b1 0b 89 00 00      	move r18, r2, true, 0x800004c0
80000ca0: 70 36 00 00 63 60 00 00      	move r0, 6753280
80000ca8: 50 33 00 00 e3 60 00 00      	move r1, 3476480
;         for (int z = 0; z < out_HW[conv_num]; z += TASK_NUM) {
80000cb0: 00 80 0d 46 63 7a 00 00      	ld d20, zero, 464
80000cb8: 00 00 14 40 57 81 00 00      	lsl r2, r21, 1
80000cc0: 00 80 c3 43 0b 71 00 00      	lhs r2, r2, 316
80000cc8: 00 00 42 44 60 7e 00 00      	sw zero, 68, r1
80000cd0: 00 00 80 44 60 7e 00 00      	sw zero, 72, r0
;         for (int z = 0; z < out_HW[conv_num]; z += TASK_NUM) {
80000cd8: 16 02 10 96 0b 3c 00 00      	jlts r2, 1, 0x800010b0
;         T* buffer_inAB = buffer_inA;
80000ce0: 00 00 83 44 e3 79 00 00      	lw r19, zero, 56
80000ce8: 00 00 00 00 e3 67 00 00      	move r15, 0
80000cf0: 0f f0 ff 00 0b 58 00 00      	and r16, r2, 65535
80000cf8: 00 00 00 b0 3f 89 00 00      	move r18, r15
80000d00: a7 01 00 b1 3f 87 00 00      	move r14, r15, true, 0x80000d38
;                 write_offset += size;
80000d08: 00 00 c4 00 3e 2d 00 00      	add r18, r15, r18
80000d10: 00 00 e0 00 e3 67 00 00      	move r15, 14
;         for (int z = 0; z < out_HW[conv_num]; z += TASK_NUM) {
80000d18: 00 00 14 40 57 80 00 00      	lsl r0, r21, 1
80000d20: 00 80 c3 43 03 78 00 00      	lhs r16, r0, 316
80000d28: 00 00 e0 00 3b 07 00 00      	add r14, r14, 14
80000d30: 17 02 c0 97 3a 3c 00 00      	jges r14, r16, 0x800010b8
;             for(int t = 0;t < cin[conv_num] / input_groups[conv_num];t ++){
80000d38: 00 00 14 40 57 80 00 00      	lsl r0, r21, 1
80000d40: 00 80 41 43 03 70 00 00      	lhs r0, r0, 276
80000d48: 00 80 36 41 d7 78 00 00      	lbs r17, r21, 355
80000d50: 00 00 00 b0 c7 80 00 00      	move r1, r17
80000d58: 00 40 5a 00 e3 8b 00 00      	call r23, __div32
80000d60: e8 01 10 96 03 3c 00 00      	jlts r0, 1, 0x80000f40
80000d68: ff ff 4e 45 59 7e 00 00      	sw r22, -60, r15
;             offset = z * PAD(out_HW[conv_num]);
80000d70: 00 00 00 b0 43 80 00 00      	move r0, r16
80000d78: ff ff 0c 45 59 7e 00 00      	sw r22, -64, r14
80000d80: 00 00 00 b0 bb 80 00 00      	move r1, r14
80000d88: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
80000d90: 00 00 00 b0 03 88 00 00      	move r16, r0
80000d98: bf 01 00 b1 e3 87 00 00      	move r15, zero, true, 0x80000df8
;                 barrier_wait(&my_barrier);
80000da0: 00 80 01 00 63 60 00 00      	move r0, 272
80000da8: 00 40 d5 00 e3 8b 00 00      	call r23, barrier_wait
;             for(int t = 0;t < cin[conv_num] / input_groups[conv_num];t ++){
80000db0: 00 80 0d 46 63 7a 00 00      	ld d20, zero, 464
80000db8: 00 00 14 40 57 80 00 00      	lsl r0, r21, 1
80000dc0: 00 80 41 43 03 70 00 00      	lhs r0, r0, 276
80000dc8: 00 80 36 41 d7 78 00 00      	lbs r17, r21, 355
80000dd0: 00 00 10 00 bf 07 00 00      	add r15, r15, 1
80000dd8: 00 00 00 b0 c7 80 00 00      	move r1, r17
80000de0: 00 40 5a 00 e3 8b 00 00      	call r23, __div32
80000de8: 00 00 00 b0 bb 89 00 00      	move r19, r14
;             for(int t = 0;t < cin[conv_num] / input_groups[conv_num];t ++){
80000df0: e5 01 c0 97 3c 3c 00 00      	jges r15, r0, 0x80000f28
;                 for(int b = 0;b < input_groups[conv_num];b ++,offset += output_HXW[conv_num]){
80000df8: 00 00 50 30 47 80 00 00      	extsb r0, r17
80000e00: e0 01 10 96 03 3c 00 00      	jlts r0, 1, 0x80000f00
80000e08: 00 00 00 00 63 60 00 00      	move r0, 0
80000e10: cf 01 00 b1 83 80 00 00      	move r1, r0, true, 0x80000e78
80000e18: ff ff ff ff e3 62 00 00      	move r5, -1
;     __builtin_dpu_ldma(to, from, nb_of_bytes);
80000e20: 00 00 3a 20 88 82 00 00      	lsr_add r5, r5, r2, 3
80000e28: 00 00 86 50 94 81 00 00      	lsl_add r3, r3, r5, 24
80000e30: 00 00 08 00 0c 70 00 00      	ldma r3, r4, 0
;                 for(int b = 0;b < input_groups[conv_num];b ++,offset += output_HXW[conv_num]){
80000e38: 00 80 0d 44 e3 7a 00 00      	lw r21, zero, 464
80000e40: 00 00 24 40 d7 81 00 00      	lsl r3, r21, 2
80000e48: 00 80 07 44 8f 71 00 00      	lw r3, r3, 368
80000e50: 00 80 36 41 57 72 00 00      	lbs r4, r21, 355
;                     buffer_offset += size;
80000e58: 00 00 c0 00 08 0c 00 00      	add r0, r2, r0
;                 for(int b = 0;b < input_groups[conv_num];b ++,offset += output_HXW[conv_num]){
80000e60: 00 00 10 00 87 00 00 00      	add r1, r1, 1
80000e68: 00 00 c0 00 0e 2c 00 00      	add r16, r3, r16
80000e70: e0 01 c8 97 04 3c 00 00      	jges r1, r4, 0x80000f00
;                     int size = TASK_NUM * PAD(out_HW[conv_num]);
80000e78: 00 00 14 40 57 81 00 00      	lsl r2, r21, 1
80000e80: 00 80 c3 43 0b 71 00 00      	lhs r2, r2, 316
80000e88: 00 00 44 44 e3 71 00 00      	lw r3, zero, 68
;                     int size = TASK_NUM * PAD(out_HW[conv_num]);
80000e90: 00 00 44 40 0b 82 00 00      	lsl r4, r2, 4
80000e98: 00 00 18 60 08 81 00 00      	lsl_sub r2, r4, r2, 1
80000ea0: 00 00 c0 00 0e 0e 00 00      	add r4, r3, r16
80000ea8: 00 10 10 00 e3 62 00 00      	move r5, 2049
80000eb0: 00 00 c0 00 cc 0d 00 00      	add r3, r19, r0
80000eb8: c3 01 ca 96 08 3c 00 00      	jlts r2, r5, 0x80000e18
;     __builtin_dpu_ldma(to, from, nb_of_bytes);
80000ec0: 00 00 08 ff 0c 70 00 00      	ldma r3, r4, 255
;                         mram_read(inputAB + offset + 2048, buffer_inAB + buffer_offset + 2048, (size - 2048));
80000ec8: 00 00 44 44 63 72 00 00      	lw r4, zero, 68
80000ed0: 00 00 c0 00 12 0e 00 00      	add r4, r4, r16
80000ed8: 00 10 00 00 13 02 00 00      	add r4, r4, 2048
80000ee0: 00 10 00 00 8f 01 00 00      	add r3, r3, 2048
80000ee8: ff 1f 00 ff 8b 02 00 00      	add r5, r2, -2048
80000ef0: ff ff ff ff 63 63 00 00      	move r6, -1
;     __builtin_dpu_ldma(to, from, nb_of_bytes);
80000ef8: c5 01 3c 21 94 82 00 00      	lsr_add r5, r6, r5, 3, true, 0x80000e28
;                 if(buffer_inAB == buffer_inA){
80000f00: 00 00 83 44 63 70 00 00      	lw r0, zero, 56
80000f08: 00 00 04 44 63 77 00 00      	lw r14, zero, 64
;                 buffer_in = buffer_inAB;    //给计算线程
80000f10: 00 00 c6 44 62 7e 00 00      	sw zero, 76, r19
;                 if(buffer_inAB == buffer_inA){
80000f18: b4 01 c0 82 4c 3c 00 00      	jeq r19, r0, 0x80000da0
80000f20: b4 01 00 b1 03 87 00 00      	move r14, r0, true, 0x80000da0
80000f28: 00 00 00 b0 bb 89 00 00      	move r19, r14
80000f30: ff ff 0c 44 5b 77 00 00      	lw r14, r22, -64
80000f38: ff ff 4c 44 db 77 00 00      	lw r15, r22, -60
;             if(finish_line){
80000f40: 14 02 00 82 3f 3c 00 00      	jz r15, 0x800010a0
;                 int size = finish_line * out_HW[conv_num];
80000f48: 00 00 14 40 57 80 00 00      	lsl r0, r21, 1
80000f50: 00 80 c3 43 83 70 00 00      	lhs r1, r0, 316
80000f58: 00 00 00 b0 3f 80 00 00      	move r0, r15
80000f60: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
;                 for (int i = 0; i < cout[conv_num]; ++i) {
80000f68: 00 80 e2 41 d7 70 00 00      	lbs r1, r21, 302
;                 int size = finish_line * out_HW[conv_num];
80000f70: 00 00 00 b0 83 87 00 00      	move r15, r0
;                 for (int i = 0; i < cout[conv_num]; ++i) {
80000f78: a1 01 10 96 07 3c 00 00      	jlts r1, 1, 0x80000d08
80000f80: ff 1f 00 ff bf 08 00 00      	add r17, r15, -2048
80000f88: fa 01 00 b1 63 88 00 00      	move r16, zero, true, 0x80000fd0
80000f90: ff ff ff ff 63 60 00 00      	move r0, -1
;     __builtin_dpu_sdma(from, to, nb_of_bytes);
80000f98: 00 00 30 20 3c 80 00 00      	lsr_add r0, r0, r15, 3
80000fa0: 00 00 82 50 00 80 00 00      	lsl_add r0, r1, r0, 24
80000fa8: 02 00 04 00 00 70 00 00      	sdma r0, r2, 0
;                 for (int i = 0; i < cout[conv_num]; ++i) {
80000fb0: 00 80 0d 46 63 7a 00 00      	ld d20, zero, 464
80000fb8: 00 80 e2 41 57 70 00 00      	lbs r0, r21, 302
80000fc0: 00 00 10 00 43 08 00 00      	add r16, r16, 1
80000fc8: a1 01 c0 97 40 3c 00 00      	jges r16, r0, 0x80000d08
;                     int cout_offset = i * output_HXW[conv_num];
80000fd0: 00 00 24 40 57 80 00 00      	lsl r0, r21, 2
80000fd8: 00 80 07 44 03 70 00 00      	lw r0, r0, 368
80000fe0: 00 00 00 b0 c3 80 00 00      	move r1, r16
80000fe8: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
80000ff0: 00 00 03 44 e3 70 00 00      	lw r1, zero, 48
80000ff8: 00 00 84 44 63 71 00 00      	lw r2, zero, 72
80001000: 00 00 c4 00 86 0c 00 00      	add r1, r1, r18
80001008: 00 00 c0 00 84 0c 00 00      	add r1, r1, r0
80001010: 00 00 c4 00 0a 0d 00 00      	add r2, r2, r18
80001018: 00 10 10 00 e3 61 00 00      	move r3, 2049
80001020: 00 00 c0 00 08 0d 00 00      	add r2, r2, r0
;                     if(size > 2048){
80001028: f2 01 c6 96 3c 3c 00 00      	jlts r15, r3, 0x80000f90
;     __builtin_dpu_sdma(from, to, nb_of_bytes);
80001030: 02 00 04 ff 04 70 00 00      	sdma r1, r2, 255
;                         mram_write(buffer_out + write_offset + cout_offset + 2048, outputAB + write_offset + cout_offset + 2048, (size - 2048));
80001038: 00 00 03 44 e3 70 00 00      	lw r1, zero, 48
80001040: 00 00 84 44 63 71 00 00      	lw r2, zero, 72
80001048: 00 00 c4 00 86 0c 00 00      	add r1, r1, r18
80001050: 00 00 c0 00 84 0c 00 00      	add r1, r1, r0
80001058: 00 10 00 00 87 00 00 00      	add r1, r1, 2048
80001060: 00 00 c4 00 0a 0d 00 00      	add r2, r2, r18
80001068: 00 00 c0 00 08 0c 00 00      	add r0, r2, r0
80001070: 00 10 00 00 03 00 00 00      	add r0, r0, 2048
80001078: ff ff ff ff 63 61 00 00      	move r2, -1
;     __builtin_dpu_sdma(from, to, nb_of_bytes);
80001080: 00 00 34 20 44 81 00 00      	lsr_add r2, r2, r17, 3
80001088: 00 00 82 50 88 80 00 00      	lsl_add r1, r1, r2, 24
80001090: 02 00 00 00 04 70 00 00      	sdma r1, r0, 0
80001098: 00 80 6f 00 63 8c 00 00      	jump 0x80000fb0
800010a0: 00 00 c0 00 e3 67 00 00      	move r15, 12
800010a8: a3 01 00 b1 63 89 00 00      	move r18, zero, true, 0x80000d18
800010b0: 00 00 00 00 63 69 00 00      	move r18, 0
;         finish = 1;
800010b8: 00 00 c1 00 e3 67 00 00      	move r15, 28
800010c0: 00 00 01 40 3f 7c 00 00      	sb r15, 0, 1
;         barrier_wait(&my_barrier);
800010c8: 00 80 01 00 63 60 00 00      	move r0, 272
800010d0: 00 40 d5 00 e3 8b 00 00      	call r23, barrier_wait
;         int size = finish_line * out_HW[conv_num];
800010d8: 00 80 0d 44 63 70 00 00      	lw r0, zero, 464
;         for (int i = 0; i < cout[conv_num]; ++i) {
800010e0: 00 80 e2 41 83 70 00 00      	lbs r1, r0, 302
800010e8: 44 02 10 96 07 3c 00 00      	jlts r1, 1, 0x80001220
800010f0: 00 00 14 40 83 80 00 00      	lsl r1, r0, 1
800010f8: 00 80 c3 43 07 78 00 00      	lhs r16, r1, 316
80001100: 00 00 44 40 c3 88 00 00      	lsl r17, r16, 4
80001108: ff 1f 00 ff c7 09 00 00      	add r19, r17, -2048
80001110: 2b 02 00 b1 63 87 00 00      	move r14, zero, true, 0x80001158
80001118: ff ff ff ff 63 60 00 00      	move r0, -1
;     __builtin_dpu_sdma(from, to, nb_of_bytes);
80001120: 00 00 30 20 44 80 00 00      	lsr_add r0, r0, r17, 3
80001128: 00 00 82 50 00 80 00 00      	lsl_add r0, r1, r0, 24
80001130: 02 00 04 00 00 70 00 00      	sdma r0, r2, 0
;         for (int i = 0; i < cout[conv_num]; ++i) {
80001138: 00 80 0d 44 63 70 00 00      	lw r0, zero, 464
80001140: 00 80 e2 41 83 70 00 00      	lbs r1, r0, 302
80001148: 00 00 10 00 3b 07 00 00      	add r14, r14, 1
80001150: 44 02 c2 97 38 3c 00 00      	jges r14, r1, 0x80001220
;             int cout_offset = i * output_HXW[conv_num];
80001158: 00 00 24 40 03 80 00 00      	lsl r0, r0, 2
80001160: 00 80 07 44 03 70 00 00      	lw r0, r0, 368
80001168: 00 00 00 b0 bb 80 00 00      	move r1, r14
80001170: 00 40 8b 00 e3 8b 00 00      	call r23, __mulsi3
80001178: 00 00 03 44 e3 70 00 00      	lw r1, zero, 48
80001180: 00 00 84 44 63 71 00 00      	lw r2, zero, 72
80001188: 00 00 c4 00 86 0c 00 00      	add r1, r1, r18
80001190: 00 00 c0 00 84 0c 00 00      	add r1, r1, r0
80001198: 00 00 c4 00 0a 0d 00 00      	add r2, r2, r18
800011a0: 00 00 c0 00 08 0d 00 00      	add r2, r2, r0
800011a8: 23 02 18 96 43 3c 00 00      	jlts r16, 129, 0x80001118
;     __builtin_dpu_sdma(from, to, nb_of_bytes);
800011b0: 02 00 04 ff 04 70 00 00      	sdma r1, r2, 255
;                 mram_write(buffer_out + write_offset + cout_offset + 2048, outputAB + write_offset + cout_offset + 2048, (size - 2048));
800011b8: 00 00 03 44 e3 70 00 00      	lw r1, zero, 48
800011c0: 00 00 84 44 63 71 00 00      	lw r2, zero, 72
800011c8: 00 00 c4 00 86 0c 00 00      	add r1, r1, r18
800011d0: 00 00 c0 00 84 0c 00 00      	add r1, r1, r0
800011d8: 00 10 00 00 87 00 00 00      	add r1, r1, 2048
800011e0: 00 00 c4 00 0a 0d 00 00      	add r2, r2, r18
800011e8: 00 00 c0 00 08 0c 00 00      	add r0, r2, r0
800011f0: 00 10 00 00 03 00 00 00      	add r0, r0, 2048
800011f8: ff ff ff ff 63 61 00 00      	move r2, -1
;     __builtin_dpu_sdma(from, to, nb_of_bytes);
80001200: 00 00 34 20 4c 81 00 00      	lsr_add r2, r2, r19, 3
80001208: 00 00 82 50 88 80 00 00      	lsl_add r1, r1, r2, 24
80001210: 02 00 00 00 04 70 00 00      	sdma r1, r0, 0
80001218: 00 40 72 00 63 8c 00 00      	jump 0x80001138
;         finish = 0;
80001220: 00 00 00 40 3f 7c 00 00      	sb r15, 0, 0
80001228: 00 00 00 00 63 60 00 00      	move r0, 0
;     return 0;
80001230: ff ff 0a 46 5b 7a 00 00      	ld d20, r22, -96
80001238: ff ff 8a 46 5b 79 00 00      	ld d18, r22, -88
80001240: ff ff 0b 46 5b 78 00 00      	ld d16, r22, -80
80001248: ff ff 8b 46 5b 77 00 00      	ld d14, r22, -72
80001250: ff ff 8f 46 5b 7b 00 00      	ld d22, r22, -8
80001258: 00 00 00 00 5f 8c 00 00      	jump r23

80001260 <mem_alloc_nolock>:
80001260: 00 80 4b 44 e3 70 00 00      	lw r1, zero, 436
80001268: 54 02 00 82 03 3c 00 00      	jz r0, 0x800012a0
80001270: 00 00 70 00 87 00 00 00      	add r1, r1, 7
80001278: ff ff 8f ff 87 50 00 00      	and r1, r1, -8
80001280: 52 02 c0 15 04 0c 00 00      	add r0, r1, r0, nc, 0x80001290
80001288: 00 00 10 20 63 7e 00 00      	fault 1
80001290: ff ff ff 40 03 71 00 00      	lbu r2, r0, -1
80001298: 00 80 40 45 e0 7d 00 00      	sw zero, 436, r0
800012a0: 00 00 00 b0 07 80 00 00      	move r0, r1
800012a8: 00 00 00 00 5f 8c 00 00      	jump r23

800012b0 <mem_alloc>:
800012b0: 00 00 0d 46 5a 7c 00 00      	sd r22, 0, d22
800012b8: 00 00 80 00 5b 0b 00 00      	add r22, r22, 8
800012c0: 58 02 ac 83 63 7c 00 00      	acquire zero, 202, nz, 0x800012c0
800012c8: 00 40 c4 00 e3 8b 00 00      	call r23, mem_alloc_nolock
800012d0: 5b 02 ac 80 63 7c 00 00      	release zero, 202, nz, 0x800012d8
800012d8: ff ff 8f 46 5b 7b 00 00      	ld d22, r22, -8
800012e0: 00 00 00 00 5f 8c 00 00      	jump r23

800012e8 <barrier_wait>:
800012e8: 00 00 30 41 83 70 00 00      	lbs r1, r0, 3
800012f0: 5e 02 00 83 07 7c 00 00      	acquire r1, 0, nz, 0x800012f0
800012f8: 00 00 10 40 83 71 00 00      	lbu r3, r0, 1
80001300: 00 00 00 40 03 71 00 00      	lbu r2, r0, 0
80001308: 6d 02 10 82 0f 3c 00 00      	jeq r3, 1, 0x80001368
80001310: 00 00 00 b0 73 82 00 00      	move r4, id
80001318: 7a 02 ff 82 0b 3c 00 00      	jeq r2, 255, 0x800013d0
80001320: 00 80 8b 41 8b 72 00 00      	lbs r5, r2, 440
80001328: 00 80 8a 41 90 7d 00 00      	sb r4, 440, r5
80001330: 00 80 88 41 88 7d 00 00      	sb r2, 440, r4
80001338: 00 00 08 40 00 7c 00 00      	sb r0, 0, r4
80001340: ff ff ff ff 0f 01 00 00      	add r2, r3, -1
80001348: 00 00 14 40 00 7c 00 00      	sb r0, 1, r2
80001350: 6b 02 00 80 07 7c 00 00      	release r1, 0, nz, 0x80001358
80001358: 00 00 00 20 f3 7e 00 00      	stop
80001360: 00 00 00 00 5f 8c 00 00      	jump r23
80001368: 78 02 ff 82 0b 3c 00 00      	jeq r2, 255, 0x800013c0
80001370: 00 80 8b 40 8b 71 00 00      	lbu r3, r2, 440
80001378: 74 02 c4 82 0c 3c 00 00      	jeq r3, r2, 0x800013a0
80001380: 70 02 00 23 0f 7d 00 00      	resume r3, 0, nz, 0x80001380
80001388: 00 00 ff 00 8f 51 00 00      	and r3, r3, 255
80001390: 00 80 8b 40 8f 71 00 00      	lbu r3, r3, 440
80001398: 70 02 c4 83 0c 3c 00 00      	jneq r3, r2, 0x80001380
800013a0: 74 02 00 23 0b 7d 00 00      	resume r2, 0, nz, 0x800013a0
800013a8: 0f 00 0f 40 03 7c 00 00      	sb r0, 0, -1
800013b0: 00 00 20 41 03 71 00 00      	lbs r2, r0, 2
800013b8: 00 00 14 40 00 7c 00 00      	sb r0, 1, r2
800013c0: 79 02 00 80 07 7c 00 00      	release r1, 0, nz, 0x800013c8
800013c8: 00 00 00 00 5f 8c 00 00      	jump r23
800013d0: 00 80 88 41 90 7d 00 00      	sb r4, 440, r4
800013d8: 00 40 76 00 63 8c 00 00      	jump 0x80001338

800013e0 <__udiv32>:
800013e0: a4 02 30 38 87 81 00 00      	clz r3, r1, max, __udiv32_division_by_zero
800013e8: 00 00 30 30 03 82 00 00      	clz r4, r0
800013f0: a3 02 c6 9b 90 0d 00 00      	sub r3, r4, r3, gtu, __udiv32_result_0
800013f8: 00 00 00 b0 07 82 00 00      	move r4, r1
80001400: 00 00 00 b0 03 90 00 00      	move.u d0, r0
80001408: 00 40 1a 00 0f 8c 00 00      	jump r3, 0x2a1
80001410: 00 00 f1 70 10 80 00 00      	div_step d0, r4, d0, 31
80001418: 00 00 e1 70 10 80 00 00      	div_step d0, r4, d0, 30
80001420: 00 00 d1 70 10 80 00 00      	div_step d0, r4, d0, 29
80001428: 00 00 c1 70 10 80 00 00      	div_step d0, r4, d0, 28
80001430: 00 00 b1 70 10 80 00 00      	div_step d0, r4, d0, 27
80001438: 00 00 a1 70 10 80 00 00      	div_step d0, r4, d0, 26
80001440: 00 00 91 70 10 80 00 00      	div_step d0, r4, d0, 25
80001448: 00 00 81 70 10 80 00 00      	div_step d0, r4, d0, 24
80001450: 00 00 71 70 10 80 00 00      	div_step d0, r4, d0, 23
80001458: 00 00 61 70 10 80 00 00      	div_step d0, r4, d0, 22
80001460: 00 00 51 70 10 80 00 00      	div_step d0, r4, d0, 21
80001468: 00 00 41 70 10 80 00 00      	div_step d0, r4, d0, 20
80001470: 00 00 31 70 10 80 00 00      	div_step d0, r4, d0, 19
80001478: 00 00 21 70 10 80 00 00      	div_step d0, r4, d0, 18
80001480: 00 00 11 70 10 80 00 00      	div_step d0, r4, d0, 17
80001488: 00 00 01 70 10 80 00 00      	div_step d0, r4, d0, 16
80001490: 00 00 f1 60 10 80 00 00      	div_step d0, r4, d0, 15
80001498: 00 00 e1 60 10 80 00 00      	div_step d0, r4, d0, 14
800014a0: 00 00 d1 60 10 80 00 00      	div_step d0, r4, d0, 13
800014a8: 00 00 c1 60 10 80 00 00      	div_step d0, r4, d0, 12
800014b0: 00 00 b1 60 10 80 00 00      	div_step d0, r4, d0, 11
800014b8: 00 00 a1 60 10 80 00 00      	div_step d0, r4, d0, 10
800014c0: 00 00 91 60 10 80 00 00      	div_step d0, r4, d0, 9
800014c8: 00 00 81 60 10 80 00 00      	div_step d0, r4, d0, 8
800014d0: 00 00 71 60 10 80 00 00      	div_step d0, r4, d0, 7
800014d8: 00 00 61 60 10 80 00 00      	div_step d0, r4, d0, 6
800014e0: 00 00 51 60 10 80 00 00      	div_step d0, r4, d0, 5
800014e8: 00 00 41 60 10 80 00 00      	div_step d0, r4, d0, 4
800014f0: 00 00 31 60 10 80 00 00      	div_step d0, r4, d0, 3
800014f8: 00 00 21 60 10 80 00 00      	div_step d0, r4, d0, 2
80001500: 00 00 11 60 10 80 00 00      	div_step d0, r4, d0, 1

80001508 <__udiv32_base>:
80001508: 00 00 01 60 10 80 00 00      	div_step d0, r4, d0, 0

80001510 <__udiv32_exit>:
80001510: 00 00 00 00 5f 8c 00 00      	jump r23

80001518 <__udiv32_result_0>:
80001518: a2 02 00 b1 03 90 00 00      	move.u d0, r0, true, __udiv32_exit

80001520 <__udiv32_division_by_zero>:
80001520: 00 00 20 20 63 7e 00 00      	fault 2

80001528 <__div32>:
80001528: 00 00 0d 46 5a 7c 00 00      	sd r22, 0, d22
80001530: 00 00 80 00 5b 0b 00 00      	add r22, r22, 8
80001538: b1 02 10 32 83 81 00 00      	clo r3, r0, z, __div32_pos_dividend
80001540: ad 02 10 32 87 81 00 00      	clo r3, r1, z, __div32_neg_dividend_pos_divider

80001548 <__div32_neg_dividend_neg_divider>:
80001548: 00 00 00 00 03 20 00 00      	neg r0, r0
80001550: 00 00 00 00 87 20 00 00      	neg r1, r1
80001558: 00 40 c7 00 e3 8b 00 00      	call r23, __udiv32
80001560: b6 02 00 41 87 0c 00 00      	neg r1, r1, true, __div32_exit

80001568 <__div32_neg_dividend_pos_divider>:
80001568: 00 00 00 00 03 20 00 00      	neg r0, r0
80001570: 00 40 c7 00 e3 8b 00 00      	call r23, __udiv32
80001578: 00 00 00 00 87 20 00 00      	neg r1, r1
80001580: b6 02 00 41 03 0c 00 00      	neg r0, r0, true, __div32_exit

80001588 <__div32_pos_dividend>:
80001588: b5 02 10 32 87 81 00 00      	clo r3, r1, z, __div32_pos_dividend_pos_divider
80001590: 00 00 00 00 87 20 00 00      	neg r1, r1
80001598: 00 40 c7 00 e3 8b 00 00      	call r23, __udiv32
800015a0: b6 02 00 41 03 0c 00 00      	neg r0, r0, true, __div32_exit

800015a8 <__div32_pos_dividend_pos_divider>:
800015a8: 00 40 c7 00 e3 8b 00 00      	call r23, __udiv32

800015b0 <__div32_exit>:
800015b0: ff ff 8f 46 5b 7b 00 00      	ld d22, r22, -8
800015b8: 00 00 00 00 5f 8c 00 00      	jump r23

800015c0 <__mulsi3>:
800015c0: bb 02 c0 9b 04 3c 00 00      	jgtu r1, r0, __mulsi3_swap
800015c8: 00 00 00 b0 03 81 00 00      	move r2, r0
800015d0: bd 02 00 b1 07 80 00 00      	move r0, r1, true, __mulsi3_start

800015d8 <__mulsi3_swap>:
800015d8: 00 00 00 b0 07 81 00 00      	move r2, r1
800015e0: 00 00 00 b0 03 80 00 00      	move r0, r0

800015e8 <__mulsi3_start>:
800015e8: 00 00 00 b0 e3 80 00 00      	move r1, zero
800015f0: de 02 01 42 08 80 00 00      	mul_step d0, r2, d0, 0, z, __mulsi3_exit
800015f8: de 02 11 42 08 80 00 00      	mul_step d0, r2, d0, 1, z, __mulsi3_exit
80001600: de 02 21 42 08 80 00 00      	mul_step d0, r2, d0, 2, z, __mulsi3_exit
80001608: de 02 31 42 08 80 00 00      	mul_step d0, r2, d0, 3, z, __mulsi3_exit
80001610: de 02 41 42 08 80 00 00      	mul_step d0, r2, d0, 4, z, __mulsi3_exit
80001618: de 02 51 42 08 80 00 00      	mul_step d0, r2, d0, 5, z, __mulsi3_exit
80001620: de 02 61 42 08 80 00 00      	mul_step d0, r2, d0, 6, z, __mulsi3_exit
80001628: de 02 71 42 08 80 00 00      	mul_step d0, r2, d0, 7, z, __mulsi3_exit
80001630: de 02 81 42 08 80 00 00      	mul_step d0, r2, d0, 8, z, __mulsi3_exit
80001638: de 02 91 42 08 80 00 00      	mul_step d0, r2, d0, 9, z, __mulsi3_exit
80001640: de 02 a1 42 08 80 00 00      	mul_step d0, r2, d0, 10, z, __mulsi3_exit
80001648: de 02 b1 42 08 80 00 00      	mul_step d0, r2, d0, 11, z, __mulsi3_exit
80001650: de 02 c1 42 08 80 00 00      	mul_step d0, r2, d0, 12, z, __mulsi3_exit
80001658: de 02 d1 42 08 80 00 00      	mul_step d0, r2, d0, 13, z, __mulsi3_exit
80001660: de 02 e1 42 08 80 00 00      	mul_step d0, r2, d0, 14, z, __mulsi3_exit
80001668: de 02 f1 42 08 80 00 00      	mul_step d0, r2, d0, 15, z, __mulsi3_exit
80001670: de 02 01 52 08 80 00 00      	mul_step d0, r2, d0, 16, z, __mulsi3_exit
80001678: de 02 11 52 08 80 00 00      	mul_step d0, r2, d0, 17, z, __mulsi3_exit
80001680: de 02 21 52 08 80 00 00      	mul_step d0, r2, d0, 18, z, __mulsi3_exit
80001688: de 02 31 52 08 80 00 00      	mul_step d0, r2, d0, 19, z, __mulsi3_exit
80001690: de 02 41 52 08 80 00 00      	mul_step d0, r2, d0, 20, z, __mulsi3_exit
80001698: de 02 51 52 08 80 00 00      	mul_step d0, r2, d0, 21, z, __mulsi3_exit
800016a0: de 02 61 52 08 80 00 00      	mul_step d0, r2, d0, 22, z, __mulsi3_exit
800016a8: de 02 71 52 08 80 00 00      	mul_step d0, r2, d0, 23, z, __mulsi3_exit
800016b0: de 02 81 52 08 80 00 00      	mul_step d0, r2, d0, 24, z, __mulsi3_exit
800016b8: de 02 91 52 08 80 00 00      	mul_step d0, r2, d0, 25, z, __mulsi3_exit
800016c0: de 02 a1 52 08 80 00 00      	mul_step d0, r2, d0, 26, z, __mulsi3_exit
800016c8: de 02 b1 52 08 80 00 00      	mul_step d0, r2, d0, 27, z, __mulsi3_exit
800016d0: de 02 c1 52 08 80 00 00      	mul_step d0, r2, d0, 28, z, __mulsi3_exit
800016d8: de 02 d1 52 08 80 00 00      	mul_step d0, r2, d0, 29, z, __mulsi3_exit
800016e0: de 02 e1 52 08 80 00 00      	mul_step d0, r2, d0, 30, z, __mulsi3_exit
800016e8: de 02 f1 52 08 80 00 00      	mul_step d0, r2, d0, 31, z, __mulsi3_exit

800016f0 <__mulsi3_exit>:
800016f0: 00 00 00 b0 07 80 00 00      	move r0, r1
800016f8: 00 00 00 00 5f 8c 00 00      	jump r23
