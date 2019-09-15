;-------------------------------------------------------;
; Programa: Conta zeros e uns                           ;
; Autores: Breno Tostes, Matheus Avellar, Pedro Possato ;
; Data: 2019.09.15                                      ;
;-------------------------------------------------------;

ORG 100H
  PLVR: DB 255,255,255,254
  ADDR: DW PLVR

ORG 0H
MAIN:
  LDS ADDR        ; Passa o endereço do vetor para o SP
  LDA #1          ; Indica que queremos contar 1s
  JSR ContaUnsZeros
  HLT             ; Para o programa


ORG 50H
  I:     DB 5     ; Quantos números faltam ser lidos
  MODE:  DB 0     ; Se queremos contar 0s ou 1s
  COUNT: DB 0     ; Contador
  CURR:  DB 0     ; Número sendo analisado
  PTR_HI:DB 0     ; HIGH byte do ponteiro de retorno
  PTR_LO:DB 0     ; LOW byte do ponteiro de retorno

ContaUnsZeros: 
  STA MODE        ; Modo passado pelo acumulador
  POP             ; }
  STA PTR_LO      ;  Pega o endereço de retorno da pilha
  POP             ;  Guarda na memória
  STA PTR_HI      ; }

Conta:
  LDA I           ; }
  SUB #1          ;  I--
  STA I           ; }
  JZ LEAVE        ; Se I == 0, vamos embora
  POP             ; Pega próximo elemento da lista
  STA CURR        ; Guarda em CURR
LOOP:
  LDA CURR        ; Carrega CURR
  JZ Conta        ; Se zero, vamos pro próximo
  SHL             ; Shift para a esquerda
  STA CURR        ; Guarda em CURR
  LDA COUNT       ; Carrega o contador
  ADC #0          ; Adiciona 0 com carry
  STA COUNT       ; Guarda em COUNT
  JMP LOOP        ; Executa o loop de novo

LEAVE:
  LDA MODE        ; Carrega o modo
  JZ ContaZeros   ; Se for 0, vai para ContaZeros
Cont:
  LDA PTR_HI      ; }
  PUSH            ;  Pega o endereço de retorno da memória
  LDA PTR_LO      ;  Guarda na pilha
  PUSH            ; }
  LDA COUNT       ; Retorna o valor contado
  RET             ; Retorna da subrotina

ContaZeros:
  LDA #32         ; Se precisamos contar os zeros,
  SUB COUNT       ; fazemos 32 - <qt. 1s> = <qt. 0s>
  STA COUNT       ; Atualiza a contagem
  JMP Cont        ; Volta para o fim da rotina
