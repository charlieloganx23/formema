================================================================================
   GUIA DE ESTRUTURA DO FORMULÁRIO EMATECH
   Modelo de Referência para Desenvolvimento de Formulários Multi-Seção
================================================================================

📋 ÍNDICE:
1. Visão Geral da Arquitetura
2. Estrutura HTML
3. Estilos CSS
4. Lógica JavaScript
5. Tipos de Questões (Exemplos Práticos)
6. Sistema Likert (Escala de 1-5)
7. Navegação Entre Seções
8. Validação de Campos
9. Campos Condicionais
10. Boas Práticas

================================================================================
1. VISÃO GERAL DA ARQUITETURA
================================================================================

CONCEITO:
- Formulário multi-seção (wizard) com navegação sequencial
- Uma seção visível por vez (class "active")
- Progress bar dinâmica baseada no progresso
- Validação por seção antes de avançar
- Campos condicionais aparecem/escondem baseado em respostas
- Armazenamento local (IndexedDB) para trabalho offline

ESTRUTURA DE ARQUIVOS:
- index.html (3894 linhas) - Estrutura do formulário
- styles.css (862 linhas) - Visual e animações
- script.js (2908 linhas) - Lógica e navegação
- db.js - Armazenamento IndexedDB
- sync.js - Sincronização com servidor

TECNOLOGIAS:
- HTML5 semântico
- CSS3 (Grid, Flexbox, Animations)
- JavaScript Vanilla (ES6+)
- IndexedDB para persistência offline

================================================================================
2. ESTRUTURA HTML
================================================================================

2.1 CONTAINER PRINCIPAL
------------------------
<div class="container">
    <header class="header">
        <!-- Logo, título, indicadores de status -->
    </header>
    
    <div class="progress-bar">
        <div class="progress-fill" id="progressBar"></div>
    </div>
    
    <form id="surveyForm" class="survey-form">
        <!-- Seções aqui -->
    </form>
</div>

2.2 ANATOMIA DE UMA SEÇÃO
--------------------------
<section class="form-section active" id="section-0">
    <!-- Header da Seção -->
    <div class="section-header">
        <h3>Módulo I - Título da Seção</h3>
        <p class="text-muted">Tempo estimado: 5 minutos</p>
    </div>
    
    <!-- Info Box (opcional) -->
    <div class="info-box">
        <p><strong>Instruções importantes</strong></p>
        <p>Texto explicativo sobre a seção...</p>
    </div>
    
    <!-- Questões -->
    <div class="question-group">
        <!-- Conteúdo da questão -->
    </div>
    
    <!-- Botões de Navegação -->
    <div class="navigation-buttons">
        <button type="button" class="btn btn-secondary" onclick="previousSection()">
            Voltar
        </button>
        <button type="button" class="btn btn-primary" onclick="nextSection()">
            Próximo
        </button>
    </div>
</section>

CLASSES CSS IMPORTANTES:
- .form-section: Container da seção
- .active: Seção visível (display: block)
- .section-header: Cabeçalho colorido
- .info-box: Caixa de informações/alertas
- .question-group: Container de cada questão
- .navigation-buttons: Botões fixos no final

================================================================================
3. ESTILOS CSS
================================================================================

3.1 VARIÁVEIS CSS (Paleta de Cores)
------------------------------------
:root {
    --primary-color: #2e7d32;      /* Verde principal */
    --secondary-color: #558b2f;    /* Verde escuro */
    --accent-color: #7cb342;       /* Verde claro */
    --text-dark: #1b5e20;          /* Texto escuro */
    --text-light: #ffffff;         /* Texto claro */
    --bg-light: #f1f8e9;           /* Fundo claro */
    --bg-white: #ffffff;           /* Fundo branco */
    --border-color: #c5e1a5;       /* Borda */
    --error-color: #d32f2f;        /* Erro/obrigatório */
    --warning-color: #f57c00;      /* Aviso */
    --success-color: #388e3c;      /* Sucesso */
    --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

3.2 CLASSES PARA QUESTÕES
--------------------------
/* Container da questão */
.question-group {
    margin-bottom: 30px;
}

/* Label da questão */
.question-label {
    display: block;
    font-weight: 600;
    font-size: 1.1em;
    color: var(--text-dark);
    margin-bottom: 15px;
}

/* Campo obrigatório (adiciona asterisco vermelho) */
.question-label.required::after {
    content: " *";
    color: var(--error-color);
}

/* Descrição/ajuda abaixo do label */
.question-description {
    font-size: 0.95em;
    color: #666;
    margin-top: 5px;
    font-style: italic;
}

3.3 ANIMAÇÕES
-------------
/* Fade in ao mostrar seção */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.form-section.active {
    display: block;
    animation: fadeIn 0.5s ease;
}

/* Slide down para campos condicionais */
@keyframes slideDown {
    from {
        opacity: 0;
        max-height: 0;
        transform: translateY(-10px);
    }
    to {
        opacity: 1;
        max-height: 200px;
        transform: translateY(0);
    }
}

.conditional-field {
    animation: slideDown 0.3s ease;
}

================================================================================
4. LÓGICA JAVASCRIPT
================================================================================

4.1 VARIÁVEIS GLOBAIS
----------------------
let currentSection = 0;  // Seção ativa atual
let formData = {
    consentimento: null,
    timestampInicio: new Date().toISOString(),
    protocolo: null,
    respostas: {}
};

4.2 FUNÇÃO DE NAVEGAÇÃO (nextSection)
--------------------------------------
function nextSection() {
    const currentSectionElement = document.getElementById(`section-${currentSection}`);
    
    // 1. Validar seção atual
    if (!validateSection(currentSectionElement)) {
        alert('Por favor, preencha todos os campos obrigatórios');
        return;
    }
    
    // 2. Salvar dados da seção
    saveCurrentSection();
    
    // 3. Remover classe active
    currentSectionElement.classList.remove('active');
    
    // 4. Avançar contador
    currentSection++;
    
    // 5. Ativar próxima seção
    const nextSectionElement = document.getElementById(`section-${currentSection}`);
    nextSectionElement.classList.add('active');
    
    // 6. Atualizar barra de progresso
    updateProgressBar();
    
    // 7. Scroll para topo
    window.scrollTo(0, 0);
}

4.3 VALIDAÇÃO DE SEÇÃO
-----------------------
function validateSection(sectionElement) {
    // Buscar todos os campos obrigatórios
    const requiredFields = sectionElement.querySelectorAll('[required]');
    
    for (let field of requiredFields) {
        if (field.type === 'radio') {
            const name = field.name;
            const checked = sectionElement.querySelector(`input[name="${name}"]:checked`);
            if (!checked) {
                field.focus();
                return false;
            }
        } else if (!field.value.trim()) {
            field.focus();
            return false;
        }
    }
    
    return true;
}

4.4 BARRA DE PROGRESSO
-----------------------
function updateProgressBar() {
    const totalSections = 7;  // Número total de seções
    const progress = ((currentSection + 1) / totalSections) * 100;
    document.getElementById('progressBar').style.width = progress + '%';
}

================================================================================
5. TIPOS DE QUESTÕES (EXEMPLOS PRÁTICOS)
================================================================================

5.1 CAMPO DE TEXTO SIMPLES
---------------------------
HTML:
<div class="question-group">
    <label class="question-label required">
        1. Nome completo
    </label>
    <input type="text" 
           name="nome_completo" 
           class="input-field" 
           placeholder="Digite seu nome completo"
           required
           maxlength="100">
</div>

CSS:
.input-field {
    width: 100%;
    padding: 15px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 1em;
    transition: all 0.3s ease;
}

.input-field:focus {
    outline: none;
    border-color: var(--primary-color);
    box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
}

5.2 SELECT (DROPDOWN)
---------------------
HTML:
<div class="question-group">
    <label class="question-label required">
        2. Município
    </label>
    <select name="municipio" class="input-field" required>
        <option value="">Selecione o município</option>
        <option value="Porto Velho">Porto Velho</option>
        <option value="Ariquemes">Ariquemes</option>
        <option value="Ji-Paraná">Ji-Paraná</option>
        <!-- mais opções -->
    </select>
</div>

5.3 RADIO BUTTONS (ESCOLHA ÚNICA)
----------------------------------
HTML:
<div class="question-group">
    <label class="question-label required">
        3. Você recebe assistência técnica?
    </label>
    <div class="radio-group">
        <label class="radio-label">
            <input type="radio" name="recebe_ater" value="sim" required>
            <span>Sim</span>
        </label>
        <label class="radio-label">
            <input type="radio" name="recebe_ater" value="nao" required>
            <span>Não</span>
        </label>
        <label class="radio-label">
            <input type="radio" name="recebe_ater" value="nao_sei" required>
            <span>Não sei</span>
        </label>
    </div>
</div>

CSS:
.radio-group {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.radio-label {
    display: flex;
    align-items: center;
    padding: 15px;
    background: #fafafa;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.radio-label:hover {
    background: var(--bg-light);
    border-color: var(--accent-color);
    transform: translateX(5px);  /* Efeito de deslize */
}

.radio-label input[type="radio"] {
    width: 20px;
    height: 20px;
    margin-right: 12px;
    cursor: pointer;
    accent-color: var(--primary-color);
}

.radio-label span {
    flex: 1;
    font-size: 1em;
}

5.4 CHECKBOXES (MÚLTIPLA ESCOLHA)
----------------------------------
HTML:
<div class="question-group">
    <label class="question-label">
        4. Quais culturas você produz? (marque até 3)
    </label>
    <div class="checkbox-group">
        <label class="checkbox-label">
            <input type="checkbox" 
                   name="culturas" 
                   value="cafe" 
                   onchange="limitCheckboxes('culturas', 3)">
            <span>Café</span>
        </label>
        <label class="checkbox-label">
            <input type="checkbox" 
                   name="culturas" 
                   value="cacau" 
                   onchange="limitCheckboxes('culturas', 3)">
            <span>Cacau</span>
        </label>
        <label class="checkbox-label">
            <input type="checkbox" 
                   name="culturas" 
                   value="banana" 
                   onchange="limitCheckboxes('culturas', 3)">
            <span>Banana</span>
        </label>
    </div>
    <p class="text-muted">Máximo de 3 opções</p>
</div>

JavaScript (limitar checkboxes):
function limitCheckboxes(name, max) {
    const checkboxes = document.querySelectorAll(`input[name="${name}"]:checked`);
    const allCheckboxes = document.querySelectorAll(`input[name="${name}"]`);
    
    if (checkboxes.length >= max) {
        allCheckboxes.forEach(cb => {
            if (!cb.checked) {
                cb.disabled = true;
            }
        });
    } else {
        allCheckboxes.forEach(cb => {
            cb.disabled = false;
        });
    }
}

5.5 TEXTAREA (TEXTO LONGO)
---------------------------
HTML:
<div class="question-group">
    <label class="question-label">
        5. Observações
    </label>
    <textarea name="observacoes" 
              class="input-field" 
              rows="5" 
              placeholder="Digite observações gerais..."
              style="resize: vertical; min-height: 120px;"></textarea>
</div>

5.6 INPUT NUMÉRICO
------------------
HTML:
<div class="question-group">
    <label class="question-label">
        6. Área da propriedade (hectares)
    </label>
    <input type="number" 
           name="area_hectares" 
           class="input-field" 
           placeholder="0.00"
           step="0.01"
           min="0"
           max="10000">
</div>

5.7 INPUT DE DATA
-----------------
HTML:
<div class="question-group">
    <label class="question-label">
        7. Data da visita
    </label>
    <input type="date" 
           name="data_visita" 
           class="input-field" 
           required>
</div>

================================================================================
6. SISTEMA LIKERT (ESCALA DE 1-5)
================================================================================

CONCEITO:
Escala visual para avaliar níveis de concordância/satisfação/utilidade.
Cada opção é um botão grande com número e descrição.

6.1 HTML COMPLETO
-----------------
<div class="question-group">
    <label class="question-label">
        H1b. Quão útil foi essa capacitação?
    </label>
    <p class="question-description">
        Escala de 1 (não foi útil) a 5 (extremamente útil)
    </p>
    
    <div class="likert-scale">
        <!-- Opção 1 -->
        <label class="likert-label">
            <input type="radio" name="h1b_utilidade" value="1">
            <span class="likert-number">1</span>
            <span class="likert-text">Nada</span>
        </label>
        
        <!-- Opção 2 -->
        <label class="likert-label">
            <input type="radio" name="h1b_utilidade" value="2">
            <span class="likert-number">2</span>
            <span class="likert-text">Pouco</span>
        </label>
        
        <!-- Opção 3 -->
        <label class="likert-label">
            <input type="radio" name="h1b_utilidade" value="3">
            <span class="likert-number">3</span>
            <span class="likert-text">Regular</span>
        </label>
        
        <!-- Opção 4 -->
        <label class="likert-label">
            <input type="radio" name="h1b_utilidade" value="4">
            <span class="likert-number">4</span>
            <span class="likert-text">Muito</span>
        </label>
        
        <!-- Opção 5 -->
        <label class="likert-label">
            <input type="radio" name="h1b_utilidade" value="5">
            <span class="likert-number">5</span>
            <span class="likert-text">Extremamente</span>
        </label>
    </div>
</div>

6.2 CSS COMPLETO
----------------
/* Container horizontal com espaçamento igual */
.likert-scale {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-top: 15px;
}

/* Cada opção (flex item) */
.likert-label {
    flex: 1;                        /* Divide espaço igualmente */
    display: flex;
    flex-direction: column;         /* Número acima, texto abaixo */
    align-items: center;
    padding: 15px 10px;
    background: #fafafa;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: center;
}

/* Efeito hover (antes de selecionar) */
.likert-label:hover {
    background: var(--bg-light);
    border-color: var(--accent-color);
    transform: translateY(-3px);    /* Levanta levemente */
}

/* Esconder radio button nativo */
.likert-label input[type="radio"] {
    display: none;
}

/* Número grande */
.likert-number {
    font-size: 1.8em;
    font-weight: bold;
    color: var(--primary-color);
    margin-bottom: 8px;
}

/* Texto descritivo */
.likert-text {
    font-size: 0.85em;
    color: #666;
    font-weight: 500;
}

/* Estado SELECIONADO (usando :has() - moderno) */
.likert-label:has(input:checked) {
    background: var(--primary-color);  /* Verde sólido */
    border-color: var(--primary-color);
    transform: translateY(-3px);       /* Mantém levantado */
}

.likert-label:has(input:checked) .likert-number,
.likert-label:has(input:checked) .likert-text {
    color: white;                      /* Texto branco ao selecionar */
}

/* RESPONSIVO: Mobile */
@media (max-width: 768px) {
    .likert-scale {
        flex-wrap: wrap;               /* Quebra linha em telas pequenas */
    }
    
    .likert-label {
        min-width: calc(20% - 8px);    /* 5 itens por linha */
        padding: 12px 5px;
    }
    
    .likert-number {
        font-size: 1.5em;
    }
    
    .likert-text {
        font-size: 0.75em;
    }
}

6.3 VARIAÇÕES DE ESCALA
------------------------
CONCORDÂNCIA:
1 = "Discordo totalmente"
2 = "Discordo"
3 = "Neutro"
4 = "Concordo"
5 = "Concordo totalmente"

FREQUÊNCIA:
1 = "Nunca"
2 = "Raramente"
3 = "Às vezes"
4 = "Frequentemente"
5 = "Sempre"

SATISFAÇÃO:
1 = "Muito insatisfeito"
2 = "Insatisfeito"
3 = "Neutro"
4 = "Satisfeito"
5 = "Muito satisfeito"

IMPORTÂNCIA:
1 = "Nada importante"
2 = "Pouco importante"
3 = "Moderadamente importante"
4 = "Importante"
5 = "Extremamente importante"

DIFICULDADE:
1 = "Muito fácil"
2 = "Fácil"
3 = "Médio"
4 = "Difícil"
5 = "Muito difícil"

================================================================================
7. NAVEGAÇÃO ENTRE SEÇÕES
================================================================================

7.1 BOTÕES DE NAVEGAÇÃO
------------------------
HTML:
<div class="navigation-buttons">
    <button type="button" 
            class="btn btn-secondary" 
            onclick="previousSection()">
        ← Voltar
    </button>
    <button type="button" 
            class="btn btn-primary" 
            onclick="nextSection()">
        Próximo →
    </button>
</div>

CSS:
.navigation-buttons {
    display: flex;
    justify-content: space-between;
    margin-top: 40px;
    gap: 15px;
}

.btn {
    padding: 15px 30px;
    font-size: 1.1em;
    font-weight: 600;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    min-width: 150px;
}

.btn-primary {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    color: white;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(46, 125, 50, 0.3);
}

.btn-secondary {
    background: #9e9e9e;
    color: white;
}

.btn-secondary:hover {
    background: #757575;
    transform: translateY(-2px);
}

7.2 SISTEMA DE SEÇÕES
----------------------
JavaScript:
// Array com IDs das seções
const sections = [
    'section-0',  // Módulo I
    'section-1',  // Módulo A
    'section-2',  // Módulo B
    'section-3',  // Módulo C
    // etc...
];

function nextSection() {
    if (currentSection < sections.length - 1) {
        hideSection(currentSection);
        currentSection++;
        showSection(currentSection);
        updateProgressBar();
    }
}

function previousSection() {
    if (currentSection > 0) {
        hideSection(currentSection);
        currentSection--;
        showSection(currentSection);
        updateProgressBar();
    }
}

function showSection(index) {
    const section = document.getElementById(sections[index]);
    section.classList.add('active');
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function hideSection(index) {
    const section = document.getElementById(sections[index]);
    section.classList.remove('active');
}

================================================================================
8. VALIDAÇÃO DE CAMPOS
================================================================================

8.1 VALIDAÇÃO HTML5 NATIVA
---------------------------
<!-- Campo obrigatório -->
<input type="text" required>

<!-- Comprimento mínimo/máximo -->
<input type="text" minlength="3" maxlength="100">

<!-- Validação de email -->
<input type="email" required>

<!-- Número com limites -->
<input type="number" min="0" max="100" step="0.1">

<!-- Padrão regex -->
<input type="text" pattern="[0-9]{11}" title="Digite 11 dígitos">

8.2 VALIDAÇÃO CUSTOMIZADA (JavaScript)
---------------------------------------
function validateSection(sectionElement) {
    let valid = true;
    const errors = [];
    
    // 1. Validar campos obrigatórios
    const requiredInputs = sectionElement.querySelectorAll('input[required], select[required], textarea[required]');
    requiredInputs.forEach(input => {
        if (!input.value.trim()) {
            valid = false;
            errors.push(`Campo obrigatório: ${input.name}`);
            input.classList.add('error');
        }
    });
    
    // 2. Validar radio buttons obrigatórios
    const radioGroups = {};
    sectionElement.querySelectorAll('input[type="radio"][required]').forEach(radio => {
        radioGroups[radio.name] = true;
    });
    
    Object.keys(radioGroups).forEach(name => {
        const checked = sectionElement.querySelector(`input[name="${name}"]:checked`);
        if (!checked) {
            valid = false;
            errors.push(`Selecione uma opção: ${name}`);
        }
    });
    
    // 3. Mostrar erros
    if (!valid) {
        alert('Corrija os seguintes erros:\n\n' + errors.join('\n'));
    }
    
    return valid;
}

8.3 FEEDBACK VISUAL DE ERRO
----------------------------
CSS:
.input-field.error {
    border-color: var(--error-color);
    background: #ffebee;
}

.error-message {
    color: var(--error-color);
    font-size: 0.9em;
    margin-top: 5px;
    display: none;
}

.input-field.error + .error-message {
    display: block;
}

JavaScript (mostrar erro):
function showError(input, message) {
    input.classList.add('error');
    
    let errorDiv = input.nextElementSibling;
    if (!errorDiv || !errorDiv.classList.contains('error-message')) {
        errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        input.parentNode.insertBefore(errorDiv, input.nextSibling);
    }
    
    errorDiv.textContent = message;
}

function clearError(input) {
    input.classList.remove('error');
    const errorDiv = input.nextElementSibling;
    if (errorDiv && errorDiv.classList.contains('error-message')) {
        errorDiv.remove();
    }
}

================================================================================
9. CAMPOS CONDICIONAIS
================================================================================

CONCEITO:
Campos que aparecem/desaparecem baseado em respostas anteriores.
Exemplo: "Se respondeu SIM na Q3, mostrar Q3a, Q3b"

9.1 HTML ESTRUTURA
------------------
<!-- Questão principal -->
<div class="question-group">
    <label class="question-label">
        3. Você recebe assistência técnica?
    </label>
    <div class="radio-group">
        <label class="radio-label">
            <input type="radio" 
                   name="recebe_ater" 
                   value="sim" 
                   onchange="handleAterChange()">
            <span>Sim</span>
        </label>
        <label class="radio-label">
            <input type="radio" 
                   name="recebe_ater" 
                   value="nao" 
                   onchange="handleAterChange()">
            <span>Não</span>
        </label>
    </div>
</div>

<!-- Campos condicionais (inicialmente escondidos) -->
<div id="ater_sim_container" style="display: none;">
    <div class="question-group">
        <label class="question-label">
            3a. Quem presta essa assistência?
        </label>
        <input type="text" name="ater_prestador" class="input-field">
    </div>
    
    <div class="question-group">
        <label class="question-label">
            3b. Com que frequência?
        </label>
        <select name="ater_frequencia" class="input-field">
            <option value="">Selecione</option>
            <option value="semanal">Semanal</option>
            <option value="mensal">Mensal</option>
            <option value="trimestral">Trimestral</option>
        </select>
    </div>
</div>

9.2 JAVASCRIPT (MOSTRAR/OCULTAR)
---------------------------------
function handleAterChange() {
    const aterSim = document.querySelector('input[name="recebe_ater"][value="sim"]');
    const container = document.getElementById('ater_sim_container');
    
    if (aterSim.checked) {
        // Mostrar campos condicionais
        container.style.display = 'block';
        
        // Tornar campos obrigatórios
        container.querySelectorAll('input, select').forEach(field => {
            field.setAttribute('required', 'required');
        });
    } else {
        // Ocultar campos condicionais
        container.style.display = 'none';
        
        // Remover obrigatoriedade
        container.querySelectorAll('input, select').forEach(field => {
            field.removeAttribute('required');
            field.value = '';  // Limpar valor
        });
    }
}

9.3 PADRÕES COMUNS
------------------
PADRÃO 1: Checkbox "Outro" com campo de texto
<label class="checkbox-label">
    <input type="checkbox" 
           name="motivos" 
           value="outro" 
           onchange="handleOutroChange()">
    <span>Outro</span>
</label>

<div id="outro_container" class="conditional-field" style="display: none;">
    <input type="text" 
           name="motivos_outro" 
           class="input-field" 
           placeholder="Especifique">
</div>

JavaScript:
function handleOutroChange() {
    const checkbox = document.querySelector('input[value="outro"]');
    const container = document.getElementById('outro_container');
    
    container.style.display = checkbox.checked ? 'block' : 'none';
    
    if (!checkbox.checked) {
        container.querySelector('input').value = '';
    }
}

PADRÃO 2: Radio com múltiplos destinos
function handleModuloRouting() {
    const value = document.querySelector('input[name="tipo_produtor"]:checked').value;
    
    if (value === 'familia') {
        // Ir para Módulo B (públicos prioritários)
        currentSection = 2;
    } else if (value === 'medio') {
        // Pular para Módulo C
        currentSection = 3;
    }
    
    showSection(currentSection);
}

================================================================================
10. BOAS PRÁTICAS
================================================================================

10.1 PERFORMANCE
----------------
✅ Usar IDs únicos para elementos manipulados frequentemente
✅ Cache de seletores DOM usados repetidamente
✅ Usar event delegation quando possível
✅ Minimizar repaints/reflows (batch DOM changes)
✅ Lazy load de seções não visíveis

EXEMPLO:
// ❌ MAU (busca DOM repetidamente)
function updateFields() {
    document.getElementById('field1').value = 'x';
    document.getElementById('field2').value = 'y';
    document.getElementById('field3').value = 'z';
}

// ✅ BOM (cache de elementos)
const fields = {
    field1: document.getElementById('field1'),
    field2: document.getElementById('field2'),
    field3: document.getElementById('field3')
};

function updateFields() {
    fields.field1.value = 'x';
    fields.field2.value = 'y';
    fields.field3.value = 'z';
}

10.2 ACESSIBILIDADE (A11Y)
---------------------------
✅ Labels sempre associados a inputs
✅ ARIA labels para elementos complexos
✅ Suporte a navegação por teclado
✅ Contraste adequado (mínimo 4.5:1)
✅ Mensagens de erro descritivas
✅ Focus visível em elementos interativos

EXEMPLOS:
<!-- Label com for + id -->
<label for="nome" class="question-label">Nome</label>
<input type="text" id="nome" name="nome">

<!-- ARIA para elementos customizados -->
<div role="radiogroup" aria-labelledby="question-label">
    <span id="question-label">Selecione uma opção:</span>
    <!-- radio buttons -->
</div>

<!-- Focus visível -->
input:focus, select:focus, textarea:focus {
    outline: 3px solid var(--primary-color);
    outline-offset: 2px;
}

10.3 RESPONSIVIDADE
-------------------
✅ Design mobile-first
✅ Breakpoints claros (768px, 1024px)
✅ Touch targets de 44x44px mínimo
✅ Texto legível sem zoom (min 16px)
✅ Imagens responsivas

BREAKPOINTS:
/* Mobile (padrão) */
.container {
    padding: 20px;
}

/* Tablet */
@media (min-width: 768px) {
    .container {
        padding: 40px;
    }
    
    .likert-scale {
        gap: 15px;
    }
}

/* Desktop */
@media (min-width: 1024px) {
    .container {
        max-width: 900px;
    }
    
    .radio-group {
        flex-direction: row;
        flex-wrap: wrap;
    }
}

10.4 NOMENCLATURA
-----------------
✅ Classes descritivas (BEM ou similar)
✅ IDs únicos e semânticos
✅ Name attributes consistentes
✅ Comentários para seções complexas

PADRÕES:
<!-- Classes BEM-like -->
<div class="question-group">
    <label class="question-group__label">...</label>
    <input class="question-group__input question-group__input--error">
</div>

<!-- IDs descritivos -->
<div id="modulo-b-container">
<div id="questao-3a-container">
<input id="input-nome-produtor">

<!-- Names com prefixo de módulo -->
<input name="a_recebe_ater">     <!-- Módulo A -->
<input name="b_publico_mulher">  <!-- Módulo B -->
<input name="c_fonte_agua">      <!-- Módulo C -->

10.5 SEGURANÇA
--------------
✅ Validar SEMPRE no servidor (nunca confiar no cliente)
✅ Sanitizar inputs antes de armazenar
✅ Escapar HTML ao renderizar user input
✅ CSRF tokens em formulários críticos
✅ Rate limiting em APIs

EXEMPLO (sanitização):
function sanitizeInput(input) {
    return input
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .trim();
}

10.6 PERSISTÊNCIA DE DADOS
---------------------------
✅ Auto-save periódico (a cada 30s)
✅ Save ao trocar de seção
✅ Recuperação de sessão interrompida
✅ Sincronização offline → online

EXEMPLO (auto-save):
let autoSaveTimer;

function enableAutoSave() {
    autoSaveTimer = setInterval(() => {
        saveFormData();
        console.log('Auto-save executado');
    }, 30000);  // 30 segundos
}

function saveFormData() {
    const data = {
        currentSection: currentSection,
        formData: getFormValues(),
        timestamp: new Date().toISOString()
    };
    
    localStorage.setItem('form_draft', JSON.stringify(data));
}

function restoreFormData() {
    const saved = localStorage.getItem('form_draft');
    if (saved) {
        const data = JSON.parse(saved);
        // Restaurar valores...
    }
}

10.7 TESTES
-----------
✅ Teste em múltiplos navegadores (Chrome, Firefox, Safari, Edge)
✅ Teste em dispositivos reais (Android, iOS)
✅ Teste offline (Service Worker)
✅ Teste com dados extremos (strings longas, caracteres especiais)
✅ Teste de validação (campos vazios, inválidos)
✅ Teste de navegação (voltar/avançar, refresh)

CHECKLIST DE TESTE:
[ ] Todos os campos salvam corretamente
[ ] Validação impede avanço com erros
[ ] Campos condicionais aparecem/desaparecem
[ ] Barra de progresso atualiza
[ ] Dados persistem após refresh
[ ] Funciona offline
[ ] Sincroniza ao voltar online
[ ] Navegação voltar/próximo funciona
[ ] Formulário completo gera protocolo
[ ] Dados chegam corretamente no banco

================================================================================
EXEMPLO COMPLETO: QUESTÃO COM LIKERT + CONDICIONAL
================================================================================

<!-- Questão Principal (Radio) -->
<div class="question-group">
    <label class="question-label required">
        H1. Nos últimos 2 anos, você participou de alguma capacitação?
    </label>
    <div class="radio-group">
        <label class="radio-label">
            <input type="radio" 
                   name="h1_participou" 
                   value="sim" 
                   onchange="handleH1Change()"
                   required>
            <span>Sim</span>
        </label>
        <label class="radio-label">
            <input type="radio" 
                   name="h1_participou" 
                   value="nao" 
                   onchange="handleH1Change()"
                   required>
            <span>Não</span>
        </label>
    </div>
</div>

<!-- Campo Condicional 1: Qual tema (aparecer se H1 = Sim) -->
<div id="h1_tema_container" style="display: none;">
    <div class="question-group">
        <label class="question-label">
            H1a. Qual foi o tema principal?
        </label>
        <div class="checkbox-group">
            <label class="checkbox-label">
                <input type="checkbox" name="h1a_tema" value="cultivo">
                <span>Técnicas de cultivo</span>
            </label>
            <label class="checkbox-label">
                <input type="checkbox" name="h1a_tema" value="financeiro">
                <span>Gestão financeira</span>
            </label>
            <label class="checkbox-label">
                <input type="checkbox" name="h1a_tema" value="ambiental">
                <span>Práticas ambientais</span>
            </label>
        </div>
    </div>
</div>

<!-- Campo Condicional 2: Escala Likert (aparecer se H1 = Sim) -->
<div id="h1_utilidade_container" style="display: none;">
    <div class="question-group">
        <label class="question-label">
            H1b. Quão útil foi essa capacitação?
        </label>
        <p class="question-description">
            Escala de 1 (não foi útil) a 5 (extremamente útil)
        </p>
        
        <div class="likert-scale">
            <label class="likert-label">
                <input type="radio" name="h1b_utilidade" value="1">
                <span class="likert-number">1</span>
                <span class="likert-text">Nada</span>
            </label>
            <label class="likert-label">
                <input type="radio" name="h1b_utilidade" value="2">
                <span class="likert-number">2</span>
                <span class="likert-text">Pouco</span>
            </label>
            <label class="likert-label">
                <input type="radio" name="h1b_utilidade" value="3">
                <span class="likert-number">3</span>
                <span class="likert-text">Regular</span>
            </label>
            <label class="likert-label">
                <input type="radio" name="h1b_utilidade" value="4">
                <span class="likert-number">4</span>
                <span class="likert-text">Muito</span>
            </label>
            <label class="likert-label">
                <input type="radio" name="h1b_utilidade" value="5">
                <span class="likert-number">5</span>
                <span class="likert-text">Extremamente</span>
            </label>
        </div>
    </div>
</div>

<script>
function handleH1Change() {
    const participou = document.querySelector('input[name="h1_participou"]:checked');
    const temaContainer = document.getElementById('h1_tema_container');
    const utilidadeContainer = document.getElementById('h1_utilidade_container');
    
    if (participou && participou.value === 'sim') {
        // Mostrar campos condicionais
        temaContainer.style.display = 'block';
        utilidadeContainer.style.display = 'block';
        
        // Tornar escala Likert obrigatória
        utilidadeContainer.querySelectorAll('input[type="radio"]').forEach(radio => {
            radio.setAttribute('required', 'required');
        });
    } else {
        // Ocultar campos condicionais
        temaContainer.style.display = 'none';
        utilidadeContainer.style.display = 'none';
        
        // Limpar valores e remover obrigatoriedade
        temaContainer.querySelectorAll('input').forEach(input => {
            input.checked = false;
        });
        
        utilidadeContainer.querySelectorAll('input[type="radio"]').forEach(radio => {
            radio.checked = false;
            radio.removeAttribute('required');
        });
    }
}
</script>

================================================================================
REFERÊNCIAS E RECURSOS ADICIONAIS
================================================================================

DOCUMENTAÇÃO TÉCNICA:
- MDN Web Docs: https://developer.mozilla.org/
- CSS Tricks: https://css-tricks.com/
- W3C Accessibility: https://www.w3.org/WAI/

BIBLIOTECAS ÚTEIS (OPCIONAL):
- Chart.js: Gráficos para análise de dados
- Date-fns: Manipulação de datas
- Lodash: Utilidades JavaScript
- Axios: Requisições HTTP mais fáceis

FERRAMENTAS DE TESTE:
- Chrome DevTools (Console, Network, Application)
- Lighthouse (Performance, Accessibility, SEO)
- BrowserStack (Teste cross-browser)
- WAVE (Acessibilidade)

PADRÕES DE DESIGN:
- Material Design (Google)
- Human Interface Guidelines (Apple)
- Fluent Design (Microsoft)

================================================================================
CONTATO E SUPORTE
================================================================================

Sistema desenvolvido para: EMATER-RO
Versão: 9 (Service Worker v9-network-first)
Última atualização: 07/12/2025

Este guia documenta a estrutura e padrões usados no formulário EMATECH.
Adapte conforme necessário para seu projeto específico.

================================================================================
FIM DO GUIA
================================================================================
