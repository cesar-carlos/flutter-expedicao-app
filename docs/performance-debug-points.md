# Pontos de Debug para Medição de Performance

## 📊 Estrutura de Logs

Todos os logs seguem o padrão:

```
[ETAPA] Informação, Duration: Xms
```

## 🔍 Fluxo de Execução com Timestamps

### 1️⃣ Início do Scan (`picking_card_scan.dart`)

```
🚀 [SCAN_START] Barcode: XXXXX, Time: timestamp
  ├─► Início do processamento do código de barras
  └─► Marca o tempo zero para todas as medições subsequentes
```

### 2️⃣ Bloqueio de Campo

```
🔒 [FIELD_LOCKED] Duration: Xms
  ├─► Tempo para bloquear campo (_scanState.startProcessing)
  └─► Tempo para limpar controller (_scanController.clear)
```

### 3️⃣ Validação de Status do Carrinho

```
✅ [CART_STATUS_OK] Duration: Xms
  ├─► Tempo para verificar se carrinho está em separação
  └─► Usa cache (CartStatusCache)
```

```
📊 [QUANTITY_OBTAINED] Quantity: X
  └─► Obtenção da quantidade do controller (operação instantânea)
```

### 4️⃣ Validação de Barcode

```
🔍 [VALIDATION_COMPLETE] Duration: Xms, Valid: true/false
  ├─► Tempo de validação do código de barras
  └─► Inclui busca no cache de itens e verificações de setor
```

### 5️⃣ Adição de Item

```
📦 [ADD_ITEM_START] Item: XXXXX, CodProduto: XXXXX, Quantity: X
  └─► Início do processo de adição
```

### 6️⃣ Chamada do ViewModel

```
🏗️ [VIEWMODEL_START] CodProduto: XXXXX, Quantity: X
  │
  ├─► 🔍 [CACHE_LOOKUP] Duration: Xms, Found: true/false
  │     └─► Busca O(1) no cache _itemsByCodProduto
  │
  ├─► ⚡ [VALIDATIONS_PARALLEL] Duration: Xms
  │     ├─► UserSession + Socket validation em paralelo
  │     └─► Future.wait() de 2 operações
  │
  ├─► ✅ [VALIDATIONS_OK] User: nome, Session: id
  │
  ├─► 🔄 [PRODUCT_CHANGED] From: X To: Y (se aplicável)
  │     └─► 🔄 [REFRESH_COMPLETE] Duration: Xms
  │
  ├─► ⚡ [OPTIMISTIC_UPDATE] Duration: Xms
  │     └─► Atualização local do estado (PickingState)
  │
  ├─► 🚀 [ASYNC_DISPATCHED] Duration: Xms
  │     └─► Disparo da operação em background (não bloqueia)
  │
  └─► ✅ [VIEWMODEL_RETURN] Total Duration: Xms
        └─► RETORNO IMEDIATO (otimista)
```

```
📊 [VIEWMODEL_RETURNED] Duration: Xms, Success: true/false
  └─► Tempo total da chamada ao ViewModel (deve ser ~0-5ms)
```

### 7️⃣ Callbacks de Sucesso

```
🎊 [SUCCESS_HANDLER_START] Item: XXXXX
  │
  ├─► 📊 [ITEM_STATE] WasCompleted: true/false
  │
  ├─► ⚡ [CALLBACKS_PARALLEL] Duration: Xms
  │     ├─► Future.delayed(10ms)
  │     ├─► onResetQuantity + onInvalidateCache
  │     └─► onCheckSectorCompletion
  │
  ├─► 📊 [ITEM_COMPLETION_CHECK] IsCompletedNow: true/false
  │
  ├─► 🎵 [SOUND_COMPLETED] Duration: Xms (ou)
  │   🔊 [SOUND_SCAN] Duration: Xms
  │
  └─► ✅ [SUCCESS_HANDLER_COMPLETE] Total Duration: Xms
```

### 8️⃣ Retorno de Foco

```
🎯 [FOCUS_RETURNED] Duration: Xms
  └─► Tempo para retornar foco ao scanner
```

### 9️⃣ Conclusão

```
✅ [ADD_ITEM_SUCCESS] Total Duration: Xms
  └─► Tempo total desde _addItemToSeparation até conclusão
```

```
🎉 [SCAN_COMPLETE] Total Duration: Xms
  └─► Tempo total desde início do scan até conclusão completa
```

```
🔓 [FIELD_UNLOCKED] Duration: Xms
  └─► Tempo para desbloquear campo (_scanState.stopProcessing)
```

---

### 🔄 Operação em Background (Paralela)

Estes logs aparecem **após** o retorno ao usuário:

```
🔄 [BACKGROUND_OP_START] Item: XXXXX, Timestamp: XXXXX
  │
  ├─► 🔄 [STATUS_SYNCING]
  │
  ├─► 🏗️ [USECASE_COMPLETE] Duration: Xms
  │     ├─► INSERT separation_item
  │     └─► UPDATE separate_item
  │
  ├─► ✅ [STATUS_SYNCED] AddedQuantity: X (ou)
  │   ❌ [BACKGROUND_OP_FAILED] Failure: erro
  │
  └─► 🎉 [BACKGROUND_OP_SUCCESS] Total Duration: Xms
```

Em caso de falha:

```
🔙 [REVERTING] Item: XXXXX, Quantity: -X
  ├─► Reversão da quantidade local
  └─► 🔙 [REVERTED] NewQuantity: X, Error: mensagem
      └─► 📢 [ERROR_NOTIFIED] Stream event sent
```

Após 2 segundos (se sucesso):

```
🧹 [SYNC_OPS_CLEARED] Item: XXXXX
  └─► Operações sincronizadas removidas do estado
```

---

## 📈 Métricas Esperadas (Otimista)

### Caminho Crítico (Feedback ao Usuário)

| Etapa                | Tempo Esperado |
| -------------------- | -------------- |
| FIELD_LOCKED         | < 1ms          |
| CART_STATUS_OK       | < 1ms (cache)  |
| VALIDATION_COMPLETE  | < 5ms          |
| CACHE_LOOKUP         | < 1ms (O(1))   |
| VALIDATIONS_PARALLEL | ~30-50ms       |
| OPTIMISTIC_UPDATE    | < 1ms          |
| ASYNC_DISPATCHED     | < 1ms          |
| **VIEWMODEL_RETURN** | **~35-60ms**   |
| CALLBACKS_PARALLEL   | ~10-15ms       |
| SOUND_SCAN           | ~5-10ms        |
| FOCUS_RETURNED       | < 1ms          |
| **TOTAL (Usuário)**  | **~50-90ms**   |

### Background (Não Bloqueia)

| Etapa                     | Tempo Esperado |
| ------------------------- | -------------- |
| USECASE_COMPLETE          | ~80-120ms      |
| INSERT + UPDATE           | ~70-110ms      |
| **BACKGROUND_OP_SUCCESS** | **~80-120ms**  |

### Troca de Produto

| Etapa                         | Tempo Esperado                      |
| ----------------------------- | ----------------------------------- |
| WAITING_PENDING_OPS           | ~0-500ms (depende de ops pendentes) |
| REFRESH_DONE                  | ~50-100ms                           |
| **WAIT_AND_REFRESH_COMPLETE** | **~50-600ms**                       |

---

## 🎯 Interpretação dos Resultados

### ✅ Performance Boa

```
✅ [VIEWMODEL_RETURN] Total Duration: 35ms
✅ [SUCCESS_HANDLER_COMPLETE] Total Duration: 15ms
🎉 [SCAN_COMPLETE] Total Duration: 55ms
```

### ⚠️ Performance Moderada

```
⚡ [VALIDATIONS_PARALLEL] Duration: 80ms
✅ [VIEWMODEL_RETURN] Total Duration: 85ms
🎉 [SCAN_COMPLETE] Total Duration: 120ms
```

### ❌ Performance Ruim (Gargalo Identificado)

```
⚡ [VALIDATIONS_PARALLEL] Duration: 200ms  ← GARGALO!
🔍 [CACHE_LOOKUP] Duration: 50ms  ← GARGALO!
🏗️ [USECASE_COMPLETE] Duration: 500ms  ← GARGALO!
```

---

## 🔧 Análise de Gargalos

### Se VALIDATIONS_PARALLEL > 100ms

- Problema: UserSession ou Socket validation lentos
- Solução: Implementar cache de UserSession

### Se CACHE_LOOKUP > 5ms

- Problema: Cache não foi construído ou lista muito grande
- Solução: Verificar \_rebuildItemsCache()

### Se CALLBACKS_PARALLEL > 30ms

- Problema: onCheckSectorCompletion muito lento
- Solução: Otimizar verificação de completude do setor

### Se USECASE_COMPLETE > 200ms

- Problema: Banco de dados lento ou rede lenta
- Solução: Verificar índices no BD, conexão de rede

### Se FOCUS_RETURNED > 5ms

- Problema: Delay no retorno de foco
- Solução: Verificar \_keyboardController.returnFocusToScanner()

---

## 📝 Como Usar

1. **Executar app em debug**
2. **Escanear produto**
3. **Copiar logs do console**
4. **Analisar tempos**
5. **Identificar gargalos** (valores acima do esperado)
6. **Otimizar** pontos problemáticos

### Exemplo de Análise

```
🚀 [SCAN_START] Barcode: 044606, Time: 1234567890
🔒 [FIELD_LOCKED] Duration: 0ms
✅ [CART_STATUS_OK] Duration: 1ms
📊 [QUANTITY_OBTAINED] Quantity: 1
🔍 [VALIDATION_COMPLETE] Duration: 2ms, Valid: true
✅ [VALIDATION_OK] Starting item addition
📦 [ADD_ITEM_START] Item: 00019, CodProduto: 44606, Quantity: 1
🏗️ [VIEWMODEL_START] CodProduto: 44606, Quantity: 1
🔍 [CACHE_LOOKUP] Duration: 0ms, Found: true
⚡ [VALIDATIONS_PARALLEL] Duration: 45ms  ← OK
✅ [VALIDATIONS_OK] User: João, Session: abc123
⚡ [OPTIMISTIC_UPDATE] Duration: 1ms
🚀 [ASYNC_DISPATCHED] Duration: 0ms
✅ [VIEWMODEL_RETURN] Total Duration: 47ms  ← EXCELENTE!
📊 [VIEWMODEL_RETURNED] Duration: 47ms, Success: true
🎊 [SUCCESS_HANDLER_START] Item: 00019
📊 [ITEM_STATE] WasCompleted: false
⚡ [CALLBACKS_PARALLEL] Duration: 12ms  ← OK
📊 [ITEM_COMPLETION_CHECK] IsCompletedNow: false
🔊 [SOUND_SCAN] Duration: 6ms
✅ [SUCCESS_HANDLER_COMPLETE] Total Duration: 18ms
🎯 [FOCUS_RETURNED] Duration: 0ms
✅ [ADD_ITEM_SUCCESS] Total Duration: 65ms  ← EXCELENTE!
🎉 [SCAN_COMPLETE] Total Duration: 70ms  ← EXCELENTE!
🔓 [FIELD_UNLOCKED] Duration: 70ms

# Background (não bloqueia):
🔄 [BACKGROUND_OP_START] Item: 00019, Timestamp: 1234567890
🔄 [STATUS_SYNCING]
🏗️ [USECASE_COMPLETE] Duration: 95ms  ← OK
✅ [STATUS_SYNCED] AddedQuantity: 1.0
🎉 [BACKGROUND_OP_SUCCESS] Total Duration: 96ms
🧹 [SYNC_OPS_CLEARED] Item: 00019  (após 2s)
```

**Conclusão**: Performance excelente! Usuário recebe feedback em 70ms, operação completa em background em 96ms.

---

## 🎯 Meta de Performance

- **Feedback ao Usuário**: < 100ms
- **VIEWMODEL_RETURN**: < 80ms
- **SCAN_COMPLETE**: < 120ms
- **USECASE_COMPLETE**: < 150ms (background)

---

**Última Atualização**: Janeiro 2025
