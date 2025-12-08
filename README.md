# 📋 Sistema de Autoavaliação - Extensionistas EMATER-RO

Sistema completo de coleta, armazenamento e análise de dados de autoavaliação para extensionistas da EMATER-RO, com suporte offline usando IndexedDB.

## 🎯 Funcionalidades

### ✅ Formulário de Autoavaliação (`index.html`)
- **6 Eixos Temáticos** (26 questões totais):
  - 🎓 **Eixo A**: Perfil e Formação (Q1-Q3)
  - 🎯 **Eixo B**: Atividades e Abordagem (Q4-Q7)
  - 💼 **Eixo C**: Recursos e Infraestrutura (Q8-Q12)
  - 🤝 **Eixo D**: Articulação e Parcerias (Q13-Q16)
  - 📊 **Eixo E**: Impacto e Produção (Q17-Q20)
  - 📈 **Eixo F**: Monitoramento e Avaliação (Q21-Q26)

- **Recursos**:
  - ✅ Salvamento automático local (IndexedDB)
  - ✅ Funcionamento offline completo
  - ✅ Geração de protocolo único (formato: `EXT-{timestamp}-{random}`)
  - ✅ Cálculo automático de duração de preenchimento
  - ✅ Interface responsiva (mobile/desktop)
  - ✅ Barra de progresso visual
  - ✅ Todas as questões opcionais (sem validação obrigatória)

### 📊 Painel Administrativo (`admin.html`)
- **Dashboard com Estatísticas**:
  - 📈 Total de formulários coletados
  - 🗺️ Municípios diferentes atendidos
  - 📅 Formulários dos últimos 7 dias
  - ⏳ Formulários pendentes de sincronização

- **Gestão de Dados**:
  - 👁️ Visualização detalhada de cada resposta (modal completo)
  - 🔄 Sincronização manual com Azure SQL
  - 📥 Exportação para JSON
  - 🗑️ Limpeza de dados (com confirmação dupla)
  - 📋 Tabela ordenada por data (mais recentes primeiro)
  - 💾 Sistema offline-first com sync manual

### 📈 Relatórios e Análises (`relatorios-extensionistas.html`)
- **12 Gráficos Interativos** (Chart.js 4.4.0):
  1. ⏱️ Tempo de Atuação (barras)
  2. 🎓 Formação Acadêmica (pizza)
  3. 🌾 Áreas de Especialização (barras horizontais)
  4. 👥 Produtores Atendidos (barras)
  5. 📋 Tipos de Atividades (barras horizontais)
  6. 🎯 Critérios de Priorização (pizza)
  7. 💼 Suficiência de Recursos (radar 4 eixos)
  8. 🤝 Participação em Fóruns (pizza)
  9. 🏢 Parcerias Institucionais (barras horizontais)
  10. 📊 Aumento de Produção (pizza)
  11. 📈 Indicadores Utilizados (barras horizontais)
  12. 📝 Formalização de Relatórios (pizza)

- **Mapa Geográfico** (Leaflet.js 1.9.4):
  - 🗺️ Visualização de distribuição por município
  - 📍 Marcadores com contagem de formulários
  - 🎯 Mapa centralizado em Rondônia

### 🗺️ Mapa de Cobertura (`mapa-cobertura.html`)
- **Visualização Geográfica Completa**:
  - 📍 Marcadores interativos por município
  - 📊 Tamanho proporcional ao número de formulários
  - 🎨 Cores por quantidade (azul: 1-2, laranja: 3-5, verde: 6+)
  - 🔍 Busca por município
  - 📅 Filtros por período (7 dias, 30 dias, todos)
  - 📈 Estatísticas de cobertura em tempo real

- **Funcionalidades Interativas**:
  - 🖱️ Clique no marcador para ver detalhes
  - 🔎 Zoom e navegação completa
  - 🔄 Reset de visualização
  - 📍 Focalização automática ao buscar
  - 💡 Popups informativos com estatísticas
  - 📊 Lista lateral de municípios visitados

- **Dados Exibidos**:
  - Total de formulários por município
  - Tempo de atuação predominante
  - Formação acadêmica predominante
  - Percentual de cobertura do estado
  - Municípios visitados vs. total (52 municípios RO)

## 🚀 Como Usar

### 1️⃣ Preencher Formulário
1. Abra **`index.html`** no navegador
2. Preencha as questões dos 6 eixos
3. Clique em **"Enviar Respostas"**
4. Anote o **protocolo gerado** (formato: EXT-...)
5. Dados salvos automaticamente no navegador

### 2️⃣ Visualizar Respostas
1. Abra **`admin.html`**
2. Veja estatísticas gerais no topo
3. Clique em qualquer linha para ver detalhes completos
4. Use botões de ação: Sincronizar, Exportar, Limpar
5. Clique em **"🔄 Sincronizar Agora"** para enviar dados ao servidor

### 3️⃣ Analisar Dados
1. Abra **`relatorios-extensionistas.html`**
2. Visualize 12 gráficos automáticos
3. Explore o mapa geográfico
4. Clique em marcadores para detalhes por município

### 4️⃣ Visualizar Mapa de Cobertura
1. Abra **`mapa-cobertura.html`**
2. Veja distribuição geográfica dos formulários
3. Clique nos marcadores para detalhes do município
4. Use filtros de período (7/30 dias ou todos)
5. Busque municípios específicos
6. Verifique cobertura percentual do estado

## 🗄️ Arquitetura IndexedDB

### Configuração
- **Database**: `EmatechExtensionistas` (versão 1)
- **Object Store**: `formularios`
- **Índices**:
  - `protocolo` (único) - Busca rápida
  - `municipio` - Filtros geográficos
  - `timestamp_fim` - Ordenação temporal
  - `sincronizado` - Fila de sync

### Funções Principais

```javascript
// Inicializar banco
await initDB();

// Salvar formulário
const resultado = await salvarFormulario(dados);
// Retorna: { success: true, protocolo: "EXT-...", id: 1 }

// Buscar todos
const formularios = await buscarTodosFormularios();

// Buscar por protocolo
const form = await buscarPorProtocolo("EXT-1234567890-5678");

// Estatísticas
const stats = await obterEstatisticas();
// Retorna: { total, sincronizados, naoSincronizados, municipios, ultimos7Dias }

// Exportar JSON
await exportarParaJSON();
// Download: extensionistas_YYYY-MM-DD_HH-mm.json

// Sincronizar com servidor
const resultado = await sincronizarComServidor('https://api.exemplo.com/sync');
```

## 📡 Sincronização com Servidor (Opcional)

### Backend PHP Exemplo

```php
<?php
// sync-extensionistas.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');

$data = json_decode(file_get_contents('php://input'), true);

try {
    $pdo = new PDO('mysql:host=localhost;dbname=emater', 'user', 'pass');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Converter arrays para JSON
    foreach (['q3', 'q5', 'q6', 'q7', 'q14', 'q18', 'q21'] as $campo) {
        if (isset($data[$campo]) && is_array($data[$campo])) {
            $data[$campo] = json_encode($data[$campo]);
        }
    }
    
    $stmt = $pdo->prepare("
        INSERT INTO extensionistas_formularios 
        (protocolo, timestamp_inicio, timestamp_fim, duracao_minutos, municipio, ...)
        VALUES (:protocolo, :timestamp_inicio, :timestamp_fim, ...)
    ");
    
    $stmt->execute($data);
    
    echo json_encode(['success' => true, 'protocolo' => $data['protocolo']]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
```

### Schema MySQL

```sql
CREATE TABLE extensionistas_formularios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    protocolo VARCHAR(50) UNIQUE NOT NULL,
    timestamp_inicio DATETIME,
    timestamp_fim DATETIME,
    duracao_minutos INT,
    municipio VARCHAR(100),
    
    -- Eixo A: Perfil
    q1 VARCHAR(50),
    q2 VARCHAR(100),
    q2_especifique TEXT,
    q3 JSON,
    q3_outro TEXT,
    
    -- Eixo B: Atividades
    q4 VARCHAR(50),
    q5 JSON,
    q5_outro TEXT,
    q6 JSON,
    q6_outro TEXT,
    q7 JSON,
    q7_outro TEXT,
    
    -- Eixo C: Recursos
    q8 VARCHAR(50),
    q9 VARCHAR(50),
    q10 VARCHAR(50),
    q11 VARCHAR(50),
    q12 TEXT,
    
    -- Eixo D: Parcerias
    q13 VARCHAR(50),
    q13_quais TEXT,
    q14 JSON,
    q14_outro TEXT,
    q15 VARCHAR(50),
    q16 TEXT,
    
    -- Eixo E: Impacto
    q17 VARCHAR(50),
    q18 JSON,
    q18_outro TEXT,
    q19 VARCHAR(50),
    q19_qual TEXT,
    q20 TEXT,
    
    -- Eixo F: Monitoramento
    q21 JSON,
    q21_outro TEXT,
    q22 VARCHAR(50),
    q23 VARCHAR(50),
    q23_quais TEXT,
    q24 VARCHAR(50),
    q25 INT,
    q26 TEXT,
    
    comentario_final TEXT,
    sincronizado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_municipio (municipio),
    INDEX idx_timestamp (timestamp_fim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 📊 Estrutura de Arquivos

```
formema/
├── index.html                          # Formulário principal (coleta de dados)
├── admin.html                          # Painel administrativo (gestão e sync)
├── relatorios-extensionistas.html      # Dashboard com 10 gráficos
├── mapa-cobertura.html                 # Mapa de cobertura geográfica
├── db-extensionistas.js                # Gerenciador IndexedDB (649 linhas)
├── config.js                           # Configuração Azure SQL
├── README.md                           # Documentação completa
└── index_backup.html                   # Backup do formulário
```

## 🎨 Personalização

### Alterar Cores do Tema
Procure no CSS:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```
Mude `#667eea` e `#764ba2` para suas cores.

### Adicionar Municípios no Mapa
Em `relatorios-extensionistas.html`:
```javascript
const coordenadasMunicipios = {
    'Seu Município': [latitude, longitude],
    'Porto Velho': [-8.7619, -63.9039],
    'Ji-Paraná': [-10.8777, -61.9509],
    // ...
};
```

### Modificar Logo/Títulos
Em cada HTML:
```html
<h1>📊 Seu Título Aqui</h1>
<p>Sua descrição personalizada</p>
```

## 📱 Compatibilidade

### Navegadores Suportados
- ✅ Chrome 80+ (recomendado)
- ✅ Firefox 75+
- ✅ Edge 80+
- ✅ Safari 14+
- ✅ Opera 67+

### Requisitos
- JavaScript habilitado
- IndexedDB habilitado (padrão)
- Resolução mínima: 360px (mobile)

### Armazenamento
- Cada formulário: ~3-5 KB
- 1000 formulários: ~3-5 MB
- Limite IndexedDB: 50+ MB (varia por navegador)

## 🔒 Privacidade e Segurança

- ✅ **Dados locais**: Armazenamento no navegador do usuário
- ✅ **Sem rastreamento**: Nenhum analytics externo
- ✅ **LGPD compliant**: Dados não saem sem ação explícita
- ✅ **Sincronização opcional**: Controle total do usuário
- ⚠️ **Backup importante**: Limpar cache apaga dados

## 🐛 Troubleshooting

### "Erro ao inicializar IndexedDB"
- ✅ Verifique JavaScript habilitado
- ✅ Teste em modo anônimo
- ✅ Limpe cache/cookies

### "Nenhum dado disponível"
- ✅ Preencha ao menos 1 formulário
- ✅ Verifique se está no mesmo domínio

### Gráficos não aparecem
- ✅ Verifique conexão com CDNs
- ✅ Abra console (F12) e veja erros
- ✅ Teste com internet ativa

### Protocolo não é gerado
- ✅ Verifique carregamento de `db-extensionistas.js`
- ✅ Abra DevTools → Application → IndexedDB
- ✅ Console: veja erros JavaScript

## 📋 Fluxo Completo de Uso

```
1. Extensionista acessa index.html
   ↓
2. Preenche 26 questões (6 eixos)
   ↓
3. Clica "Enviar Respostas"
   ↓
4. Sistema gera protocolo único (EXT-...)
   ↓
5. Dados salvos no IndexedDB (offline)
   ↓
6. Acessa admin.html
   ↓
7. Visualiza todas as respostas em tabela
   ↓
8. Clica "🔄 Sincronizar Agora" (formulários pendentes)
   ↓
9. Dados enviados para Azure SQL via Netlify Functions
   ↓
10. Acessa relatorios-extensionistas.html
    ↓
11. Visualiza 10 gráficos interativos
    ↓
12. Acessa mapa-cobertura.html
    ↓
13. Visualiza cobertura geográfica de Rondônia
    ↓
14. Exporta JSON para backup local
```

## 🎓 Detalhamento dos Eixos

### Eixo A: Perfil e Formação
- Q1: Tempo de atuação na EMATER
- Q2: Formação acadêmica + especificação
- Q3: Áreas de especialização (múltipla escolha)

### Eixo B: Atividades e Abordagem
- Q4: Produtores atendidos por mês
- Q5: Tipos de atividades (múltipla)
- Q6: Critérios de priorização (múltipla)
- Q7: Metodologias aplicadas (múltipla)

### Eixo C: Recursos e Infraestrutura
- Q8: Suficiência recursos técnicos (escala)
- Q9: Suficiência recursos financeiros (escala)
- Q10: Suficiência transporte/logística (escala)
- Q11: Suficiência equipamentos tech (escala)
- Q12: Limitações enfrentadas (texto livre)

### Eixo D: Articulação e Parcerias
- Q13: Participação fóruns/redes + quais
- Q14: Parcerias institucionais (múltipla)
- Q15: Frequência das parcerias
- Q16: Exemplos de parcerias (texto)

### Eixo E: Impacto e Produção
- Q17: Produtores aumentaram produção
- Q18: Principais demandas técnicas (múltipla)
- Q19: Acesso a mercados + quais
- Q20: Evidências do impacto (texto)

### Eixo F: Monitoramento e Avaliação
- Q21: Indicadores utilizados (múltipla)
- Q22: Formalização de relatórios
- Q23: Indicadores de efetividade + quais
- Q24: Frequência influência monitoramento
- Q25: Capacidade acompanhamento (Likert 1-5)
- Q26: Limitações no monitoramento (texto)

## 📞 Suporte Técnico

### Checklist de Verificação
1. ✅ Todos os arquivos na mesma pasta?
2. ✅ `db-extensionistas.js` está carregando?
3. ✅ Console do navegador (F12) mostra erros?
4. ✅ Testou em modo anônimo?
5. ✅ IndexedDB habilitado? (DevTools → Application)

### Abrir Console do Navegador
- **Windows/Linux**: `F12` ou `Ctrl+Shift+I`
- **Mac**: `Cmd+Option+I`

### Verificar IndexedDB
1. Abra DevTools (F12)
2. Aba **Application**
3. Menu lateral → **IndexedDB**
4. Expanda **EmatechExtensionistas**
5. Clique em **formularios**
6. Veja registros salvos

## 📝 Changelog

### Versão 1.0.0 (Janeiro 2024)
- ✅ Formulário completo (6 eixos, 26 questões)
- ✅ Sistema IndexedDB integrado
- ✅ Painel administrativo funcional
- ✅ Dashboard com 12 gráficos
- ✅ Mapa geográfico Leaflet (relatórios)
- ✅ Mapa de cobertura interativo dedicado (NOVO)
- ✅ Exportação JSON
- ✅ Protocolo único
- ✅ Interface responsiva
- ✅ Funcionamento 100% offline
- ✅ Validação removida (todas questões opcionais)
- ✅ Coordenadas de 52 municípios de Rondônia
- ✅ Filtros por período (7/30 dias)
- ✅ Busca por município

## 📄 Licença

Sistema desenvolvido para **EMATER-RO** (Empresa de Assistência Técnica e Extensão Rural de Rondônia).  
Uso interno institucional.

---

## 🌟 Início Rápido

```bash
# 1. Baixe os arquivos do GitHub
# 2. Abra index.html no navegador (preencha formulários)
# 3. Acesse admin.html (visualize e sincronize)
# 4. Veja relatórios em relatorios-extensionistas.html
# 5. Visualize mapa em mapa-cobertura.html
```

**Sistema offline-first com sincronização manual para Azure SQL!**

---

**Desenvolvido com ❤️ para EMATER-RO**
