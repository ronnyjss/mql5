//+------------------------------------------------------------------+
//|                                  Tendência -  Topos e Fundos.mq5 |
//|                            Copyright 2023, Ronny Santos - JSSart |
//|                                               https://jss.art.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Ronny Santos - JSSart"
#property link      "https://jss.art.br"
#property version   "1.0"

#property description "Este indicador mostra a tendência do gráfico em tempo real"
#property description "com uma linha colorida que indica compra (verde) ou venda (vermelho)"
#property description "com base nos topos e fundos do preço."
#property description "É uma ferramenta eficaz para auxiliar a compreensão da direção do mercado."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Tendência | Topos e Fundos"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  C'0,80,0', C'140,0,0'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

int input intLimiteFalhas = 3; // Número de barras toleraveis

double floLinhaBuffer[];
double floLinhaCor[];


int OnInit()
{
    SetIndexBuffer(0, floLinhaBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, floLinhaCor,    INDICATOR_COLOR_INDEX);
    return(INIT_SUCCEEDED);
}


int sentindo(
    const double &floPreco[],
    const int     intIndice
) {
    if (ArraySize(floPreco) <= intIndice + 1) {
        return 0;
    }

    int intBarrasCompra = 0, intFalhasCompra = 0,
        intBarrasVenda  = 0, intFalhasVenda  = 0,
        intTotalBarrasProcessadas = 0;

    double floPrecoCompra = floPreco[intIndice],
           floPrecoVenda  = floPreco[intIndice];

    do {
        intTotalBarrasProcessadas++;

        if (intFalhasCompra < intLimiteFalhas) {
            if(ArraySize(floPreco) <= intIndice + intTotalBarrasProcessadas) {
                intFalhasCompra = intLimiteFalhas + 1;
            } else if(floPreco[intIndice + intTotalBarrasProcessadas - 1] <= floPreco[intIndice + intTotalBarrasProcessadas]) {
                if(floPreco[intIndice + intTotalBarrasProcessadas] > floPrecoCompra) {
                    intFalhasCompra = 0;
                    floPrecoCompra  = floPreco[intIndice + intTotalBarrasProcessadas];
                    intBarrasCompra = intTotalBarrasProcessadas;
                }
            } else {
                intFalhasCompra++;
            }
        }

        if (intFalhasVenda < intLimiteFalhas) {
            if(ArraySize(floPreco) <= intIndice + intTotalBarrasProcessadas) {
                intFalhasVenda = intLimiteFalhas + 1;
            } else if(floPreco[intIndice + intTotalBarrasProcessadas - 1] >= floPreco[intIndice + intTotalBarrasProcessadas]) {
                if(floPreco[intIndice + intTotalBarrasProcessadas] < floPrecoVenda) {
                    intFalhasVenda = 0;
                    floPrecoVenda = floPreco[intIndice + intTotalBarrasProcessadas];
                    intBarrasVenda = intTotalBarrasProcessadas;
                }
            } else {
                intFalhasVenda++;
            }
        }
    } while(intFalhasCompra < intLimiteFalhas || intFalhasVenda < intLimiteFalhas);

    if(intIndice > 0) {
        floLinhaCor[intIndice] = floLinhaCor[intIndice - 1];
    }

    if(intBarrasCompra > intBarrasVenda) {
        if(intFalhasCompra == intLimiteFalhas + 1) {
            floPrecoCompra = floPreco[intIndice + intTotalBarrasProcessadas - 1];
            intBarrasCompra = intTotalBarrasProcessadas - 1;
        }

        double floTotalBarrasCompra = 0;
        for(int i = 1; i <= intBarrasCompra; i++) {
            floTotalBarrasCompra = floPrecoCompra - floPreco[intIndice];
            floLinhaBuffer[intIndice + i] = ((floTotalBarrasCompra / intBarrasCompra) * i) + floPreco[intIndice];
            floLinhaCor[intIndice + i] = 0;
        }

        return intBarrasCompra;
    } else {
        if(intFalhasVenda == intLimiteFalhas + 1) {
            floPrecoVenda = floPreco[intIndice + intTotalBarrasProcessadas - 1];
            intBarrasVenda = intTotalBarrasProcessadas - 1;
        }

        double floTotalBarrasVenda = 0;
        for(int i = 1; i <= intBarrasVenda; i++) {
            floTotalBarrasVenda = floPreco[intIndice] - floPrecoVenda;
            floLinhaBuffer[intIndice + i] = floPreco[intIndice] - ((floTotalBarrasVenda / intBarrasVenda) * i);
            floLinhaCor[intIndice + i] = 1;
        }

        return intBarrasVenda;
    }
}


int OnCalculate(
    const int       intTotalBarras,
    const int       intRetornoAnterior,
    const datetime &datTempo[],
    const double   &floAbertura[],
    const double   &floTopo[],
    const double   &floFundo[],
    const double   &floFechamento[],
    const long     &tick_volume[],
    const long     &volume[],
    const int      &spread[]
) {
    int intIndice = 0, intRetorno = 0;
    while(intIndice < intTotalBarras) {
        intRetorno = sentindo(floFechamento, intIndice);

        if(intRetorno == 0) {
            break;
        }

        intIndice += intRetorno;
    }

    return(intTotalBarras);
}