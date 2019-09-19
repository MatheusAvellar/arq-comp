;-------------------------------------------------------;
; Programa: Fibonacci                                   ;
; Autores: Breno Tostes, Matheus Avellar, Pedro Possato ;
; Data: 2019.09.18                                      ;
;-------------------------------------------------------;

BANNER      EQU 2
CLEARBANNER EQU 3

ORG 100H
  HI: DB 0
  LO: DB 0
  I:  DB 0
  VAL:DB 0
  TMP:DB 0
  RES:DB 0

ORG 0H
MAIN:
  OUT CLEARBANNER  ; Limpa o banner
  LDS #100H        ; Aponta para a pilha
Tecladinho:
  IN 3             ; Verifica se há algum valor a ser lido
  ADD #0           ; Soma com 0 para ativar flags
  JZ Tecladinho    ; Se retornou 0, volta para o loop
                   ; Senão, tem algo a ser lido no tecladinho
  IN 2             ; Lê o tecladinho
  STA TMP          ; Guarda em TMP
  OUT BANNER       ; DEBUG: Imprime do banner
  SUB #23H         ; Subtrai '#' em ASCII
  JZ Cont          ; Se chegamos a um '#', já lemos tudo
  LDA TMP          ; Senão, vamos ler o número de novo
  SUB #30H         ; Subtrai '0' em ASCII
  PUSH             ; Guarda na pilha
  LDA I            ; }
  ADD #1           ;  I++
  STA I            ; }
  SUB #2           ; Se I == 2, vamos parar de ler números
  JZ IgnorarTecladinho
  JMP Tecladinho   ; Volta para o loop
IgnorarTecladinho:
  IN 2             ; Lê o tecladinho
  SUB #23H         ; Subtrai '#' em ASCII
  JZ Cont          ; Se chegamos a um '#', já lemos tudo
  JMP IgnorarTecladinho
Cont:              ; Precisamos agora converter o valor para um byte
  POP              ; Pega a UNIDADE
  STA LO
  POP              ; Pega a DEZENA
  STA HI
                   ; Acc = <dezena>
  SHL              ; Acc *= 2        ; }
  SHL              ; Acc *= 2        ;  Acc *= 10
  ADD HI           ; Acc += <dezena> ;
  SHL              ; Acc *= 2        ; }
  ADD LO           ; Acc += <unidade>
  STA VAL          ; VAL = Acc
;------------------;
  JSR Fib          ; Chama a subrotina de Fibonacci
  STA RES          ; Guarda o resultado em RES   
  OUT CLEARBANNER  ; Limpa o banner
  JMP PrintRes     ; Imprime o resultado em hexadecimal

;##### Imprimir em hexadecimal, dado um valor #####;
BITS:  DB 0     ; Espaço para trabalhar com 4 bits
PrintRes:
  LDA RES         ; Vamos converter a parte de cima de RES
  AND #0F0H       ; AND com (1111 0000)
  SHR             ; }
  SHR             ;  Seguido de 4 shifts
  SHR             ;  à direita
  SHR             ; }
  STA BITS        ; Temos agora os 4 maiores bits do byte
  JSR PrintHex    ; Converte para hexadecimal e imprime
  LDA RES         ; Vamos converter a parte de baixo de RES
  AND #0FH        ; AND com (0000 1111)
  STA BITS        ; Temos agora os 4 menores bits do byte
  JSR PrintHex    ; Converte para hexadecimal e imprime

  LDA #48H        ; Imprime o caractere 'H'
  OUT BANNER      ; (para indicar que é hexadecimal)
  HLT

PrintHex:
  SUB #10         ; BITS - 10
  JN PrintNumber  ; Se bits < 10, é um número
                  ; Se bits >= 10, então é uma letra
  ADD #41H        ; Adiciona a posição do A em ASCII
  JMP PrintPrint  ; Imprime
PrintNumber:
  LDA BITS        ; Recupera o valor dos bits
  ADD #30H        ; Adiciona a posição do 0 em ASCII
PrintPrint:
  OUT BANNER      ; Imprime
  RET             ; Volta


ORG 500H
  PTR_LO: DB 0
  PTR_HI: DB 0
  NI:     DB 0
  NTMP:   DB 0
  NRET:   DB 0
; Sequência 1, 1, 2, 3, 5, 8, ...
Fib:
  STA NI          ; Guarda o valor recebido no Acc em NI
  SUB #2          ; Se N < 2
  JN FibRetN      ; Vai retornar NI
  JMP FibCont     ; Senão vai para FibCont
FibRetN:
  LDA NI          ; Carrega NI
  RET             ; Retorna
FibCont:
  LDA NI          ; Carrega NI
  PUSH            ; Guarda NI original
  SUB #1          ; Calcula N - 1
  JSR Fib         ; Chama Fib(N-1)
  STA NRET        ; Guarda o valor recebido
  POP             ; Pega NI original
  STA NI          ; Atualiza variável NI com o valor certo
  LDA NRET        ; Pega valor recebido, novamente
  PUSH            ; Empilha valor recebido
  LDA NI          ; Carrega NI original
  SUB #2          ; Calcula N - 2
  JSR Fib         ; Chama Fib(N-2)
  STA NTMP        ; Guarda valor recebido em NTMP
  POP             ; Pega o valor de Fib(N-1)
  ADD NTMP        ; Soma com o valor recebido
  RET             ; Retorna







