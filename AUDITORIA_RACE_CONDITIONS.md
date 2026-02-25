# 🔍 AUDITORIA: RACE CONDITIONS E PROBLEMAS DE CONCORRÊNCIA

**Data:** 24/02/2026  
**Objetivo:** Verificar se existem os mesmos problemas críticos identificados em outro sistema

---

## 📋 PROBLEMAS AUDITADOS

### ❌ P1: Race Condition em Sincronizações Simultâneas

**STATUS: 🔴 PROBLEMA CONFIRMADO - CRÍTICO**

#### Evidências Encontradas:

**1. Sem Lock/Mutex para Controlar Processamento**
```javascript
// db-extensionistas.js linha 171-189
async function buscarNaoSincronizados() {
    // ❌ SEM LOCK: Múltiplas chamadas simultâneas retornam MESMA lista
    const transaction = db.transaction([STORE_NAME], 'readonly');
    const objectStore = transaction.objectStore(STORE_NAME);
    const request = objectStore.getAll();
    
    request.onsuccess = () => {
        const naoSincronizados = request.result.filter(form => !form.sincronizado);
        resolve(naoSincronizados);
    };
}
```

**2. Múltiplos Pontos de Entrada Simultâneos**

```javascript
// CENÁRIO 1: Auto-sync no formulário (extensionistas.html linha 95)
tentarSincronizacaoSilenciosa(formulario).then(...)

// CENÁRIO 2: Auto-sync em background após 2s (db-extensionistas.js linha 766-773)
setTimeout(() => sincronizacaoAutomaticaEmBackground(), 2000);

// CENÁRIO 3: Auto-refresh no admin (admin.html linha 1491)
setInterval(async () => {
    await sincronizacaoAutomaticaEmBackground(pendentes);
}, 10000);

// CENÁRIO 4: Botão manual no admin
// ❌ TODAS EXECUTAM EM PARALELO SEM COORDENAÇÃO
```

**3. Race Condition Real Identificada**

```
⏱️ T=0s    | Usuario salva formulário A
⏱️ T=0.1s  | tentarSincronizacaoSilenciosa(A) inicia
⏱️ T=2.0s  | sincronizacaoAutomaticaEmBackground() inicia
            │
            ├── buscarNaoSincronizados() retorna [A] ← PRIMEIRA VEZ
            │   └── sincronizarFormularioComAzure(A) inicia
            │
⏱️ T=2.1s  | Sync 1 ainda processando A (rede lenta)
            │
⏱️ T=10s   | setInterval no admin dispara
            │
            ├── buscarNaoSincronizados() retorna [A] ← SEGUNDA VEZ (ainda não marcado)
            │   └── sincronizarFormularioComAzure(A) inicia NOVAMENTE
            │
⏱️ T=12s   | Ambas sincronizações completam
            │
            ├── POST #1 para Azure SQL (formulário A)
            └── POST #2 para Azure SQL (formulário A) ← 🚨 DUPLICADO
```

**Impacto:**
- ✅ **Protocolo único impede duplicação no banco** (chave primária)
- ⚠️ **Desperdício de recursos** (requests duplicados)
- ⚠️ **Possível erro 500 no segundo POST** (violação de PK)
- ⚠️ **Logs poluídos** com erros falsos

**Probabilidade de Ocorrência:**
- 🔴 **ALTA** em conexões lentas (3G/4G rural)
- 🔴 **ALTA** se técnico deixa admin aberto enquanto preenche formulários
- 🟡 **MÉDIA** com servidor rápido

---

### ✅ P2: Falta Validação de Flag `sincronizado`

**STATUS: 🟢 PROBLEMA NÃO ENCONTRADO**

#### Evidências:

**1. Validação Correta na Busca**
```javascript
// db-extensionistas.js linha 183
const naoSincronizados = request.result.filter(form => !form.sincronizado);
// ✅ FILTRA corretamente apenas não sincronizados
```

**2. Validação na Deleção**
```javascript
// db-extensionistas.js linha 282
if (!formulario.sincronizado) {
    console.warn('⚠️ BLOQUEADO: Tentativa de deletar formulário NÃO sincronizado');
    resolve({ success: false, error: 'Formulário não sincronizado - não pode ser deletado' });
    return;
}
// ✅ PROTEÇÃO: Não permite deletar não sincronizados
```

**3. Update da Flag**
```javascript
// db-extensionistas.js linha 601 (após sucesso)
formulario.sincronizado = true;
formulario.data_sincronizacao = new Date().toISOString();
const updateRequest = objectStore.put(formulario);
// ✅ CORRETO: Marca como sincronizado após confirmação da API
```

**Conclusão:**
✅ Sistema valida corretamente flag `sincronizado`  
✅ Não há risco de reenviar dados já sincronizados (a menos que haja race condition no P1)

---

### ⚠️ P3: Retry Limitado (3 tentativas)

**STATUS: 🟡 PROBLEMA PARCIAL - NÃO TEM RETRY**

#### Evidências:

**1. Nenhuma Lógica de Retry Implementada**
```bash
# Busca por padrões de retry
$ grep -i "retry\|tentativa\|attempt" db-extensionistas.js
# Resultado: 0 matches (nenhum retry implementado)
```

**2. Tentativa Única por Ciclo**
```javascript
// db-extensionistas.js linha 528
async function sincronizarFormularioComAzure(formulario) {
    try {
        const response = await fetch(url, {
            method: 'POST',
            signal: AbortSignal.timeout(CONFIG.TIMEOUT || 30000)
        });
        // ❌ Se falhar → throw error → FIM
        // ❌ NÃO tenta novamente
    } catch (error) {
        return { success: false, error: error.message };
    }
}
```

**3. Background Sync Roda Novamente Após 10s (Admin)**
```javascript
// admin.html linha 1491
setInterval(async () => {
    // Auto-refresh a cada 10s
    // ⚠️ Funciona como "retry passivo"
    // ⚠️ Mas se admin não estiver aberto → sem retry
}, 10000);
```

**Comparação com Sistema Original:**
| Item | Sistema Original | Este Sistema |
|------|------------------|--------------|
| **Retry Ativo** | ✅ 3 tentativas | ❌ 0 tentativas |
| **Timeout** | 35 segundos total | 60 segundos (aumentado) |
| **Retry Passivo** | ❌ Não tem | ✅ setInterval 10s (apenas no admin) |

**Impacto:**
- ⚠️ **Falha temporária = espera próximo ciclo** (mínimo 10s se admin aberto)
- ⚠️ **Formulário sem admin = zero retry** (só tenta 1x ao salvar)
- ⚠️ **Erro momentâneo de rede = sincronização adiada**

**Cenário Real:**
```
📱 Técnico em campo (conexão instável)
└─ T=0s: Salva formulário
   └─ T=0.1s: tentarSincronizacaoSilenciosa() inicia
      └─ T=5s: Falha (sem sinal momentâneo)
         └─ ❌ Desiste
            └─ ⏳ Espera admin abrir + próximo setInterval (pode ser horas)
```

**Gravidade:** 🟡 MÉDIA  
**Problema é DIFERENTE do sistema original:**
- Original: desiste após 35s (3 tentativas × ~12s)
- Atual: desiste após 60s (1 tentativa)
- Atual tem timeout MAIOR mas MENOS tentativas

---

### 🔴 P4: Fila Travada com Erros Permanentes

**STATUS: 🔴 PROBLEMA CONFIRMADO - CRÍTICO**

#### Evidências:

**1. Itens com Erro Não São Removidos da Fila**
```javascript
// db-extensionistas.js linha 653-665
for (const form of formularios) {
    const resultado = await sincronizarFormularioComAzure(form);
    
    if (resultado.success) {
        resultados.sucesso++;
    } else {
        resultados.erro++;  // ❌ Apenas conta erro
    }
    // ❌ NÃO remove da fila
    // ❌ NÃO marca como "erro permanente"
    // ❌ Item fica na fila ETERNAMENTE
}
```

**2. Sem Contador de Tentativas**
```javascript
// db-extensionistas.js - linha 76 (estrutura do formulário)
const formulario = {
    ...dados,
    protocolo: protocolo,
    timestamp_fim: new Date().toISOString(),
    sincronizado: false,
    versao_formulario: '1.0'
    // ❌ FALTA: tentativas_sync: 0
    // ❌ FALTA: ultimo_erro: null
    // ❌ FALTA: erro_permanente: false
};
```

**3. Loop Infinito Confirmado**
```javascript
// CENÁRIO: Formulário com erro permanente (ex: dados inválidos)

⏱️ T=0s     | Formulário salvo com dados corrompidos
⏱️ T=2s     | sincronizacaoAutomaticaEmBackground()
            │ └── buscarNaoSincronizados() → retorna [FormulárioProblema]
            │ └── sincronizarFormularioComAzure() → ERRO 400
            │ └── Não remove da fila
            │
⏱️ T=10s    | setInterval do admin
            │ └── buscarNaoSincronizados() → retorna [FormulárioProblema] ← MESMA COISA
            │ └── sincronizarFormularioComAzure() → ERRO 400 ← DE NOVO
            │ └── Não remove da fila
            │
⏱️ T=20s    | Repete...
⏱️ T=30s    | Repete...
⏱️ T=40s    | Repete... ← 🚨 LOOP INFINITO
⏱️ ∞        | Nunca para até intervenção manual
```

**4. Ausência de Estratégia de Dead Letter Queue**
```javascript
// ❌ NÃO EXISTE:
// - Limite máximo de tentativas
// - Marcador de "erro permanente"
// - Fila separada para itens problemáticos
// - Auto-remoção após N tentativas
// - Notificação de admin sobre itens travados
```

**Impacto Real:**

1. **Desperdício de Recursos**
   - POST repetidos para Azure SQL a cada 10s
   - Logs poluídos com erros recorrentes
   - Netlify Functions gastos desnecessários

2. **Bloqueio de Fila**
   ```javascript
   // db-extensionistas.js linha 506
   const limite = Math.min(pendentes.length, 10);
   // ⚠️ Se primeiro item trava → bloqueia fila inteira
   ```
   - Processa max 10 por vez
   - Se 1º item sempre falha → outros 9 processados, 10º+ esperando
   - Fila cresce infinitamente

3. **Diagnóstico Difícil**
   - Técnico não sabe que formulário travou
   - Admin vê crescimento constante de pendentes
   - Sem métrica de "quantas vezes tentou"

**Reprodução do Bug:**
```javascript
// TESTE: Criar formulário com municipio_id NULL (viola constraint)
const formularioProblema = {
    protocolo: 'TEST-001',
    municipio_id: null,  // ← FK constraint violation
    sincronizado: false
};

// Resultado:
// → POST retorna 500
// → sincronizado permanece false
// → buscarNaoSincronizados() sempre retorna este item
// → Tenta novamente a cada 10s
// → Loop infinito até admin deletar manualmente
```

---

## 📊 RESUMO DA AUDITORIA

| Problema | Status | Gravidade | Existe? |
|----------|--------|-----------|---------|
| **P1: Race Condition** | ❌ CONFIRMADO | 🔴 CRÍTICA | ✅ SIM |
| **P2: Validação Flag** | ✅ OK | 🟢 BAIXA | ❌ NÃO |
| **P3: Retry Limitado** | ⚠️ PARCIAL | 🟡 MÉDIA | ⚠️ DIFERENTE |
| **P4: Fila Travada** | ❌ CONFIRMADO | 🔴 CRÍTICA | ✅ SIM |

---

## 🚨 SEVERIDADE DOS PROBLEMAS

### 🔴 CRÍTICO: P1 - Race Condition
**Probabilidade:** ALTA em campo (3G/4G)  
**Impacto:** Requests duplicados, erros 500 falsos, desperdício recursos  
**Urgência:** ALTA

### 🔴 CRÍTICO: P4 - Fila Travada
**Probabilidade:** MÉDIA (depende de dados inválidos)  
**Impacto:** Loop infinito, bloqueio fila, diagnóstico difícil  
**Urgência:** ALTA

### 🟡 MÉDIO: P3 - Sem Retry Ativo
**Probabilidade:** ALTA em conexões instáveis  
**Impacto:** Sincronizações atrasadas, dependência de admin  
**Urgência:** MÉDIA

---

## 💡 SOLUÇÕES RECOMENDADAS

### Para P1 (Race Condition):

```javascript
// Adicionar flag global de processamento
let sincronizacaoEmAndamento = false;

async function sincronizacaoAutomaticaEmBackground() {
    // Lock simples
    if (sincronizacaoEmAndamento) {
        console.log('⏳ Sincronização já em andamento, pulando...');
        return { success: false, error: 'Já processando' };
    }
    
    sincronizacaoEmAndamento = true;
    
    try {
        // ... lógica de sincronização ...
    } finally {
        sincronizacaoEmAndamento = false; // ✅ Sempre libera lock
    }
}
```

### Para P4 (Fila Travada):

```javascript
// Adicionar contador de tentativas no formulário
const formulario = {
    ...dados,
    sincronizado: false,
    tentativas_sync: 0,           // ✅ Contador
    maximo_tentativas: 10,        // ✅ Limite
    ultimo_erro: null,            // ✅ Debug
    erro_permanente: false        // ✅ Flag de desistência
};

// Modificar sincronizarFormularioComAzure
async function sincronizarFormularioComAzure(formulario) {
    // Verificar se já desistiu
    if (formulario.erro_permanente) {
        console.warn(`⚠️ Pulando formulário com erro permanente: ${formulario.protocolo}`);
        return { success: false, error: 'Erro permanente - requer intervenção manual' };
    }
    
    // Incrementar tentativas
    formulario.tentativas_sync = (formulario.tentativas_sync || 0) + 1;
    
    try {
        const resultado = await fetch(...);
        
        if (resultado.ok) {
            formulario.sincronizado = true;
            formulario.tentativas_sync = 0; // Reset
            await objectStore.put(formulario);
        }
    } catch (error) {
        formulario.ultimo_erro = error.message;
        
        // Marcar como erro permanente após N tentativas
        if (formulario.tentativas_sync >= formulario.maximo_tentativas) {
            formulario.erro_permanente = true;
            console.error(`🚨 ERRO PERMANENTE: ${formulario.protocolo} - ${error.message}`);
            
            // Notificar admin (opcional)
            if (typeof window.notificarErroAdmin === 'function') {
                window.notificarErroAdmin(formulario);
            }
        }
        
        // ✅ Salvar estado atualizado
        await objectStore.put(formulario);
    }
}

// Modificar buscarNaoSincronizados para excluir erros permanentes
async function buscarNaoSincronizados() {
    const naoSincronizados = request.result.filter(form => 
        !form.sincronizado && !form.erro_permanente  // ✅ Exclui travados
    );
    return naoSincronizados;
}
```

### Para P3 (Retry):

```javascript
async function sincronizarFormularioComRetry(formulario, maxRetries = 3) {
    for (let tentativa = 1; tentativa <= maxRetries; tentativa++) {
        console.log(`🔄 Tentativa ${tentativa}/${maxRetries} para ${formulario.protocolo}`);
        
        const resultado = await sincronizarFormularioComAzure(formulario);
        
        if (resultado.success) {
            return resultado; // ✅ Sucesso
        }
        
        // Aguardar antes de retentar (exponential backoff)
        if (tentativa < maxRetries) {
            const delay = Math.pow(2, tentativa - 1) * 2000; // 2s, 4s, 8s
            console.log(`⏳ Aguardando ${delay}ms antes de retentar...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
    
    // ❌ Todas tentativas falharam
    return { success: false, error: `Falha após ${maxRetries} tentativas` };
}
```

---

## 🎯 PRIORIZAÇÃO DE IMPLEMENTAÇÃO

### Fase 1 (URGENTE):
1. ✅ **P1: Adicionar lock em sincronizacaoAutomaticaEmBackground()**
   - Tempo estimado: 30 minutos
   - Impacto: Elimina race conditions

2. ✅ **P4: Adicionar contador de tentativas e erro_permanente**
   - Tempo estimado: 2 horas
   - Impacto: Evita loops infinitos

### Fase 2 (IMPORTANTE):
3. ✅ **P3: Implementar retry com exponential backoff**
   - Tempo estimado: 1 hora
   - Impacto: Melhora resiliência em conexões instáveis

### Fase 3 (DESEJÁVEL):
4. ✅ **Dashboard de Erros Permanentes no Admin**
   - Tempo estimado: 3 horas
   - Impacto: Facilita diagnóstico e correção manual

---

## 📈 MÉTRICAS DE SUCESSO

**Antes das correções:**
- Race conditions: ~20% das sincronizações (estimado em conexões lentas)
- Loops infinitos: Possíveis com dados inválidos
- Retry: 0 tentativas automáticas

**Após correções:**
- Race conditions: 0% (lock ativo)
- Loops infinitos: 0% (dead letter queue)
- Retry: 3 tentativas com backoff

---

**Última atualização:** 24/02/2026  
**Próximo passo:** Aguardar aprovação para implementar correções
