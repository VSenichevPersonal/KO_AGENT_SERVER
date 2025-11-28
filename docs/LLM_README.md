> ⚠️ Агенты обязаны строго придерживаться всех правил, описанных ниже.

# LLM Development Guide



**Цель**: Этот документ описывает принципы и паттерны, которые делают проект легко поддерживаемым как людьми, так и LLM (AI coding assistants).

---

## 🎯 Принципы LLM-Friendly кода

### 0. **Эффективность и краткость кода**

**ВАЖНО**: Пишем код компактно и эффективно.

**Принципы:**

- ✅ Минимум строк для решения задачи

- ✅ Избегаем дублирования

- ✅ Используем встроенные функции языка

- ✅ Не раздуваем кодовую базу

- ✅ Один класс/функция - одна ответственность

**✅ Хорошо (компактно):**

```typescript

// INTENT: Валидация договора

export const validateContract = (text: string): string[] => {

  const errors: string[] = [];

  if (!text?.trim()) errors.push('Empty text');

  if (text.length < 100) errors.push('Too short');

  return errors;

};

```

**❌ Плохо (раздуто):**

```typescript

export class ContractValidator {

  private errors: string[] = [];

  

  constructor() {

    this.errors = [];

  }

  

  public validate(text: string): boolean {

    this.errors = [];

    this.checkIfEmpty(text);

    this.checkLength(text);

    return this.errors.length === 0;

  }

  

  private checkIfEmpty(text: string): void {

    if (!text) {

      this.errors.push('Empty text');

    }

  }

  

  private checkLength(text: string): void {

    if (text.length < 100) {

      this.errors.push('Too short');

    }

  }

  

  public getErrors(): string[] {

    return this.errors;

  }

}

```

### 1. **Язык комментариев: РУССКИЙ**

**ВАЖНО**: Все комментарии в коде пишутся **на русском языке**.

**Причины:**

- ✅ Проект для русскоязычной команды

- ✅ Бизнес-логика на русском (договоры, политики ИБ)

- ✅ LLM одинаково хорошо понимают русский и английский

- ✅ Легче понимать intent и контекст на родном языке

**Исключения (только английский):**

- Имена переменных, функций, классов (camelCase/PascalCase)

- Ключевые слова языка (const, function, class, etc.)

- Названия паттернов (Strategy, Factory, Repository)

- Технические термины из спецификаций (HTTP, REST, CORS)

#### ✅ Правильно:

```typescript

// INTENT: Сервис управляет жизненным циклом юридических договоров

// RESPONSIBILITIES: загрузка, анализ, хранение, управление lifecycle

// DEPENDENCIES: LangflowClient (AI анализ), ContractRepository (хранение)

// SIDE_EFFECTS: Вызывает внешний Langflow API, пишет в БД

// FILE: api/src/services/ContractService.ts

export class ContractService {

  /**

   * INTENT: Загрузить договор в систему и проиндексировать для анализа

   * 

   * FLOW:

   * 1. Валидация входных данных

   * 2. Сохранение в репозиторий → получение document_id

   * 3. Индексация в Langflow для AI анализа

   * 4. Возврат document_id

   * 

   * ERROR_HANDLING: Graceful degradation - документ сохраняется даже если Langflow упал

   * 

   * @param text - Текст договора

   * @param metadata - Опциональные метаданные (название, тип и т.д.)

   * @returns Promise<IngestResult> с document_id

   */

  async ingestContract(

    text: string,

    metadata?: ContractMetadata

  ): Promise<IngestResult> {

    // Implementation

  }

}

```

#### ❌ Неправильно:

```typescript

// Contract service - НЕТ, слишком кратко и на английском

export class ContractService {

  // Ingest contract - НЕТ, нет контекста

  async ingestContract(text: string, metadata?: any) {

    // Implementation

  }

}

```

### 1. **INTENT-первый подход**

Каждый файл, функция и сложная логика должны начинаться с комментария **INTENT**, объясняющего "почему" и "для чего".

#### ✅ Хорошо:

```typescript

// INTENT: Этот сервис управляет жизненным циклом юридических договоров

// RESPONSIBILITIES: загрузка, анализ, хранение, управление lifecycle

// DEPENDENCIES: LangflowClient (AI анализ), ContractRepository (хранение в БД)

// SIDE_EFFECTS: Вызывает внешний Langflow API, пишет в базу данных

// FILE: api/src/services/ContractService.ts

export class ContractService {

  /**

   * INTENT: Загрузить договор в систему и проиндексировать для анализа

   * 

   * FLOW:

   * 1. Validate input

   * 2. Save to repository → get document_id

   * 3. Index in Langflow for AI analysis

   * 4. Return document_id

   * 

   * ERROR_HANDLING: Graceful degradation - document saved even if Langflow fails

   * 

   * @param text - Raw contract text

   * @param metadata - Optional metadata (title, type, etc.)

   * @returns Promise<IngestResult> with document_id

   */

  async ingestContract(

    text: string,

    metadata?: ContractMetadata

  ): Promise<IngestResult> {

    // Implementation

  }

}

```

#### ❌ Плохо:

```typescript

// Contract service

export class ContractService {

  // Ingest contract

  async ingestContract(text: string, metadata?: any) {

    // Implementation

  }

}

```

---

### 2. **Явные PATTERN комментарии**

Используйте комментарии **PATTERN:** для обозначения применяемых архитектурных паттернов.

#### Примеры:

```typescript

// PATTERN: Dependency Injection для testability

constructor(

  private langflowClient: LangflowClient,

  private repository: IContractRepository

) {}

// PATTERN: Factory Method для создания провайдеров

static createProvider(type: string): IAIProvider {

  // ...

}

// PATTERN: Strategy для разных AI провайдеров

interface IAIProvider {

  executeFlow(flowId: string, inputs: any): Promise<any>;

}

// PATTERN: Repository для абстракции data access

interface IContractRepository {

  save(contract: Contract): Promise<string>;

  findById(id: string): Promise<Contract | null>;

}

// PATTERN: Circuit Breaker для устойчивости

const breaker = new CircuitBreaker(langflowClient.runFlow, {

  timeout: 30000,

  errorThresholdPercentage: 50,

});

```

**Распространённые паттерны в проекте:**

- Dependency Injection

- Repository Pattern

- Strategy Pattern

- Factory Pattern

- Circuit Breaker

- Retry with Exponential Backoff

- Cache-Aside

- Event-Driven

---

## ☁️ Инфраструктура AI и хранилищ

### Qdrant (векторный поиск)

- Railway service из публичного образа `qdrant/qdrant:latest`

- Port `6333`, volume `/qdrant/storage` (≥ 10 GB), private network only

- Env vars:

  ```

  QDRANT_URL=http://qdrant.railway.internal:6333

  QDRANT_API_KEY=<опционально>

  ```

- Используем для RAG через Langflow и прямой SDK (`@qdrant/js-client-rest`).

### MinIO (объектное S3-хранилище)

- Храним оригинальные договоры + вложения. В Postgres/Qdrant остаются только метаданные и извлечённый текст.

- Развёртывание (Railway → Docker Image → `minio/minio:latest`, бесплатный публичный образ):

  ```

  Start Command: server /data --console-address ":9001"

  Ports: 9000 (S3 API), 9001 (Console)

  Volume: /data (>= 10 GB)

  MINIO_ROOT_USER=credos

  MINIO_ROOT_PASSWORD=<strong-random>

  ```

- Локально можно поднять тем же образом:

  ```bash

  docker run -d --name minio \

    -p 9000:9000 -p 9001:9001 \

    -e MINIO_ROOT_USER=credos \

    -e MINIO_ROOT_PASSWORD=super-strong-pass \

    -v ./minio-data:/data \

    minio/minio:latest server /data --console-address ":9001"

  ```

- Стандартные переменные для API/Web:

  ```

  MINIO_ENDPOINT=http://minio.railway.internal:9000

  MINIO_ACCESS_KEY=credos

  MINIO_SECRET_KEY=super-strong-pass

  MINIO_BUCKET=contracts

  ```

- Каждый domain-сервис вместо прямой работы с SDK использует `StorageService`:

  ```typescript

  // FILE: api/src/services/StorageService.ts

  // INTENT: Унифицированный доступ к MinIO/S3

  export class StorageService {

    constructor(private client: Minio.Client, private bucket: string) {}

  

    // PATTERN: Upload + metadata

    async upload(buffer: Buffer, meta: { mime: string; name: string }) {

      const objectName = `${Date.now()}_${meta.name}`;

      await this.client.putObject(this.bucket, objectName, buffer, {

        'Content-Type': meta.mime,

      });

      return { objectName };

    }

  

    async getSignedUrl(objectName: string, expires = 3600) {

      return this.client.presignedGetObject(this.bucket, objectName, expires);

    }

  }

  ```

> ⚠️ **Важно:** ни один бинарный файл не хранится в Git. Все загрузки (drag&drop, attachments, отчёты) отправляются в MinIO, а ссылки сохраняются в БД.

---

### 3. **Typed Errors с контекстом**

Используйте typed domain errors с rich context для лучшего понимания и обработки.

```typescript

// INTENT: Domain-specific errors с контекстом для debugging

// PATTERN: Custom error hierarchy

export class DomainError extends Error {

  constructor(

    message: string,

    public code: string,

    public statusCode: number,

    public context?: Record<string, any>

  ) {

    super(message);

    this.name = this.constructor.name;

  }

}

// INTENT: Contract не найден - 404 error

export class ContractNotFoundError extends DomainError {

  constructor(documentId: string) {

    super(

      `Contract not found: ${documentId}`,

      'CONTRACT_NOT_FOUND',

      404,

      { documentId }

    );

  }

}

// USAGE в коде:

if (!contract) {

  throw new ContractNotFoundError(documentId);

}

// INTENT: Централизованная обработка typed errors

fastify.setErrorHandler((error, request, reply) => {

  if (error instanceof DomainError) {

    return reply.code(error.statusCode).send({

      error: error.code,

      message: error.message,

      context: error.context,

      trace_id: request.id,

    });

  }

  // ...

});

```

---

### 4. **Чистые функции и изоляция побочных эффектов**

Разделяйте pure logic и side effects для лучшей тестируемости и понимания.

#### ✅ Хорошо:

```typescript

// INTENT: Pure domain logic без побочных эффектов

// PURE_FUNCTION: Легко тестировать, легко понимать LLM

export class ContractValidator {

  /**

   * INTENT: Валидация договора по бизнес-правилам

   * PURE_FUNCTION: Нет зависимостей от внешних систем

   */

  static validate(contract: Contract): ValidationResult {

    const errors: string[] = [];

    

    if (contract.text.length < 100) {

      errors.push('Contract text too short');

    }

    

    if (!contract.metadata?.type) {

      errors.push('Contract type is required');

    }

    

    return {

      valid: errors.length === 0,

      errors,

    };

  }

}

// INTENT: Service координирует effects

export class ContractService {

  async ingestContract(text: string, metadata?: any): Promise<IngestResult> {

    const contract = Contract.create(text, metadata);

    

    // PURE: Валидация

    const validation = ContractValidator.validate(contract);

    if (!validation.valid) {

      throw new ValidationError(validation.errors);

    }

    

    // EFFECT: Сохранение в БД

    const documentId = await this.repository.save(contract);

    

    // EFFECT: Вызов внешнего API

    await this.aiProvider.executeFlow('legal_ingest', {

      text: contract.text,

      document_id: documentId,

    });

    

    // EFFECT: Логирование

    this.logger.info('Contract ingested', { documentId });

    

    return { document_id: documentId, status: 'ingested' };

  }

}

```

#### ❌ Плохо:

```typescript

// Смешивает logic, effects и hardcoded dependencies

async function ingestContract(text: string) {

  if (text.length < 100) throw new Error('Too short');

  const id = Date.now().toString();

  documents.set(id, { text }); // Hardcoded global state

  await fetch('http://langflow:7860/api/v1/run/legal_ingest', {

    method: 'POST',

    body: JSON.stringify({ text }),

  }); // Hardcoded URL

  console.log('Ingested:', id); // Side effect

  return id;

}

```

---

### 5. **Абстракции для внешних зависимостей**

Все внешние зависимости должны быть за интерфейсами для легкой замены и тестирования.

```typescript

// INTENT: Абстракция для AI провайдера - можно заменить реализацию

// PATTERN: Strategy pattern

// FILE: api/src/providers/IAIProvider.ts

export interface IAIProvider {

  /**

   * INTENT: Execute AI flow/chain

   * PROVIDER_AGNOSTIC: Работает с любым AI orchestration platform

   * 

   * @param flowId - Identifier of the flow to execute

   * @param inputs - Input data for the flow

   * @returns Flow execution result

   */

  executeFlow(flowId: string, inputs: Record<string, any>): Promise<any>;

  

  /**

   * INTENT: Health check для мониторинга

   */

  healthCheck(): Promise<boolean>;

}

// IMPLEMENTATION: Langflow provider

// FILE: api/src/providers/LangflowProvider.ts

export class LangflowProvider implements IAIProvider {

  constructor(private config: { baseUrl: string }) {}

  

  async executeFlow(flowId: string, inputs: Record<string, any>) {

    // INTENT: Вызов Langflow API

    const response = await fetch(

      `${this.config.baseUrl}/api/v1/run/${flowId}`,

      {

        method: 'POST',

        headers: { 'Content-Type': 'application/json' },

        body: JSON.stringify({ inputs }),

      }

    );

    

    if (!response.ok) {

      throw new AIProviderError('Langflow call failed', {

        flowId,

        status: response.status,

      });

    }

    

    return response.json();

  }

  

  async healthCheck(): Promise<boolean> {

    try {

      const response = await fetch(`${this.config.baseUrl}/health`);

      return response.ok;

    } catch {

      return false;

    }

  }

}

// ALTERNATIVE IMPLEMENTATION: OpenAI provider

// FILE: api/src/providers/OpenAIProvider.ts

export class OpenAIProvider implements IAIProvider {

  constructor(private config: { apiKey: string }) {}

  

  async executeFlow(flowId: string, inputs: Record<string, any>) {

    // INTENT: Map flow IDs to OpenAI Assistant IDs

    const assistantId = this.flowToAssistantMap[flowId];

    

    // INTENT: Call OpenAI Assistants API

    const response = await openai.beta.threads.createAndRun({

      assistant_id: assistantId,

      thread: {

        messages: [{ role: 'user', content: inputs.message }],

      },

    });

    

    return response;

  }

}

// PATTERN: Factory для создания нужного провайдера

// FILE: api/src/providers/AIProviderFactory.ts

export class AIProviderFactory {

  /**

   * INTENT: Создать AI provider на основе конфигурации

   * PATTERN: Factory Method

   */

  static create(config: Config): IAIProvider {

    switch (config.aiProvider) {

      case 'langflow':

        return new LangflowProvider({ baseUrl: config.langflowUrl });

      case 'openai':

        return new OpenAIProvider({ apiKey: config.openaiApiKey });

      default:

        throw new Error(`Unknown AI provider: ${config.aiProvider}`);

    }

  }

}

```

**Где нужны абстракции:**

- ✅ AI providers (Langflow, OpenAI, Anthropic)

- ✅ Data storage (in-memory, PostgreSQL, MongoDB)

- ✅ Cache (in-memory, Redis)

- ✅ Logger (console, file, external service)

- ✅ File storage (local, S3, GCS)

---

### 5.1 **Pipeline как единая точка входа**

> **TL;DR**: Если задача требует более одного Langflow-вызова — сразу добавляйте сервис-оркестратор. REST-эндпоинты и фоновые воркеры будут переиспользовать одну и ту же логику, а LLMу будет проще вносить изменения.

#### ✅ Пример: `ContractPipelineService`

```typescript

// INTENT: Унифицированный сервис для Langflow-пайплайнов договоров

// RESPONSIBILITIES: запуск шагов анализа, сбор результатов, логирование

// FILE: api/src/services/ContractPipelineService.ts

export class ContractPipelineService {

  constructor(

    private fastify: FastifyInstance,

    private documents: DocumentService

  ) {}

  async runPipeline(documentId: string, options: PipelineRunOptions, context: ExecutionContext) {

    const document = options.preloadedDocument || (await this.documents.loadDocument(documentId));

    const parties = await this.identifyContractParties(document.text, context.tenantId);

    for (const step of options.steps ?? ['risks', 'obligations', 'standards', 'counterparty']) {

      await this.executeStep(step, { document, parties, context, options });

    }

  }

  private async executeStep(step: PipelineStep, ctx: StepContext) {

    switch (step) {

      case 'risks':

        return this.runRisksStep(ctx);

      case 'obligations':

        return this.runObligationsStep(ctx);

      case 'standards':

        return this.runStandardsStep(ctx);

      case 'counterparty':

        return this.runCounterpartyStep(ctx);

    }

  }

}

```

#### Где используется

- **REST**: `POST /v1/legal/contracts/:id/pipeline` — фронт передаёт выбранные чекбоксами шаги, сервис сам решает порядок, хранит результаты и пишет в `audit_logs`.

- **Worker**: `DocumentProcessingService` больше не повторяет бизнес-правила, а просто вызывает `runPipeline` и отслеживает статус job.

- **UI**: забирает агрегированный статус через `GET /v1/legal/contracts/:id/pipeline/status` (риски, обязательства, стандарты, история).

#### Почему это важно

- ✅ Один единый источник правды: меняем промпт или формат вывода → правка в одном сервисе.

- ✅ Меньше кода в endpoint-ах, LLM быстро понимает flow и может модифицировать шаги без копипасты.

- ✅ Легко тестировать (можно мокнуть `ContractPipelineService` целиком или отдельные шаги).

- ✅ Упрощается аудит и логирование — все шаги проходят через общие хуки.

> **Рекомендация**: Любая новая фича, где >1 Langflow вызова или сложный последовательный сценарий, должна оформляться как pipeline сервис с шагами Strategy + единый endpoint `/:id/pipeline`.

---

### 6. **Структурированное логирование**

Используйте structured logging для легкого поиска и анализа.

```typescript

// INTENT: Structured logging для observability

// PATTERN: Contextual logging

import { logger } from './logger';

export class ContractService {

  async ingestContract(text: string, metadata?: any) {

    // INTENT: Логируем начало операции с контекстом

    logger.info('Starting contract ingestion', {

      operation: 'contract.ingest',

      text_length: text.length,

      metadata,

      user_id: this.context.userId,

    });

    

    try {

      const documentId = await this.repository.save(contract);

      

      // INTENT: Success log с результатом

      logger.info('Contract ingested successfully', {

        operation: 'contract.ingest',

        document_id: documentId,

        duration_ms: Date.now() - startTime,

      });

      

      return { document_id: documentId };

    } catch (error) {

      // INTENT: Error log с полным контекстом для debugging

      logger.error('Contract ingestion failed', {

        operation: 'contract.ingest',

        error: error.message,

        error_stack: error.stack,

        text_length: text.length,

        metadata,

        user_id: this.context.userId,

      });

      

      throw error;

    }

  }

}

```

**Что логировать:**

- ✅ Начало/конец операций

- ✅ Ошибки с полным контекстом

- ✅ Вызовы внешних сервисов

- ✅ Важные бизнес-события

- ❌ Персональные данные (PII)

- ❌ Секреты и токены

---

### 7. **Typed Configuration с валидацией**

Конфигурация должна быть typed и валидироваться при старте.

```typescript

// INTENT: Typed configuration с валидацией

// PATTERN: Fail-fast - приложение не стартует с невалидной конфигурацией

// FILE: api/src/config.ts

import { z } from 'zod';

// INTENT: Schema для валидации environment variables

const envSchema = z.object({

  // Application

  NODE_ENV: z.enum(['development', 'production', 'test']),

  API_PORT: z.string().regex(/^\d+$/).transform(Number),

  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),

  

  // Security

  API_KEY: z.string().min(32, 'API_KEY must be at least 32 chars for security'),

  

  // AI Provider

  AI_PROVIDER: z.enum(['langflow', 'openai', 'anthropic']).default('langflow'),

  LANGFLOW_URL: z.string().url().optional(),

  OPENAI_API_KEY: z.string().optional(),

  

  // Flow IDs (все обязательны)

  LEGAL_INGEST_FLOW_ID: z.string().min(1),

  LEGAL_REVIEW_FLOW_ID: z.string().min(1),

  INFOSEC_POLICY_FLOW_ID: z.string().min(1),

  

  // Database

  DATABASE_URL: z.string().url().optional(),

  

  // Cache

  REDIS_URL: z.string().url().optional(),

}).refine(

  (data) => {

    // INTENT: Langflow URL обязателен если провайдер - langflow

    if (data.AI_PROVIDER === 'langflow') {

      return !!data.LANGFLOW_URL;

    }

    return true;

  },

  { message: 'LANGFLOW_URL is required when AI_PROVIDER is langflow' }

);

// INTENT: Экспортируем typed config

export type Config = z.infer<typeof envSchema>;

// INTENT: Парсим и валидируем при импорте модуля

export const config: Config = envSchema.parse(process.env);

// PATTERN: Type-safe access к конфигурации

// TypeScript подсказывает доступные поля и их типы

console.log(config.API_PORT); // number

console.log(config.NODE_ENV); // 'development' | 'production' | 'test'

```

---

### 8. **Документированные типы**

Все типы и интерфейсы должны быть документированы с примерами.

```typescript

// INTENT: Domain types для юридических договоров

// FILE: api/src/domain/Contract.ts

/**

 * Тип договора

 */

export type ContractType = 

  | 'services'     // Договор оказания услуг

  | 'nda'          // Соглашение о неразглашении

  | 'employment'   // Трудовой договор

  | 'lease';       // Договор аренды

/**

 * Уровень риска в договоре

 */

export type RiskLevel = 'L' | 'M' | 'H'; // Low, Medium, High

/**

 * Метаданные договора

 * 

 * @example

 * ```typescript

 * const metadata: ContractMetadata = {

 *   title: 'Договор оказания услуг с ООО Поставщик',

 *   type: 'services',

 *   counterparty: 'ООО Поставщик',

 *   date: new Date('2024-01-15'),

 * };

 * ```

 */

export interface ContractMetadata {

  /** Название договора */

  title?: string;

  

  /** Тип договора */

  type?: ContractType;

  

  /** Контрагент */

  counterparty?: string;

  

  /** Дата договора */

  date?: Date;

  

  /** Дополнительные поля */

  [key: string]: any;

}

/**

 * Договор в системе

 * 

 * @example

 * ```typescript

 * const contract = Contract.create(

 *   'ДОГОВОР ОКАЗАНИЯ УСЛУГ\n\n...',

 *   { type: 'services', title: 'Договор №123' }

 * );

 * ```

 */

export class Contract {

  private constructor(

    public readonly text: string,

    public readonly metadata: ContractMetadata

  ) {}

  

  /**

   * INTENT: Factory method для создания договора

   * PATTERN: Factory Method

   * VALIDATION: Валидирует обязательные поля

   * 

   * @throws ValidationError если текст пустой

   */

  static create(text: string, metadata?: ContractMetadata): Contract {

    if (!text || text.trim().length === 0) {

      throw new ValidationError('Contract text cannot be empty');

    }

    

    return new Contract(text, metadata || {});

  }

  

  /**

   * INTENT: Извлечь пункты договора

   * PURE_FUNCTION: Не изменяет состояние

   */

  extractClauses(): string[] {

    // Implementation

  }

}

```

---

### 9. **Тестируемость by Design**

Код должен быть спроектирован для легкого тестирования.

```typescript

// INTENT: Dependency Injection делает код легко тестируемым

// PATTERN: Constructor injection

// FILE: api/src/services/ContractService.ts

export class ContractService {

  constructor(

    private aiProvider: IAIProvider,

    private repository: IContractRepository,

    private logger: ILogger

  ) {}

  

  async ingestContract(text: string, metadata?: any) {

    // Implementation using injected dependencies

  }

}

// INTENT: Unit test с моками

// FILE: api/src/services/__tests__/ContractService.test.ts

describe('ContractService', () => {

  let service: ContractService;

  let mockAI: jest.Mocked<IAIProvider>;

  let mockRepo: jest.Mocked<IContractRepository>;

  let mockLogger: jest.Mocked<ILogger>;

  beforeEach(() => {

    // PATTERN: Test doubles (mocks) для изоляции unit под тестом

    mockAI = {

      executeFlow: jest.fn(),

      healthCheck: jest.fn(),

    };

    

    mockRepo = {

      save: jest.fn(),

      findById: jest.fn(),

    };

    

    mockLogger = {

      info: jest.fn(),

      error: jest.fn(),

    };

    

    // INTENT: Inject mocks для тестирования в изоляции

    service = new ContractService(mockAI, mockRepo, mockLogger);

  });

  describe('ingestContract', () => {

    it('should save contract and index in AI', async () => {

      // ARRANGE

      mockRepo.save.mockResolvedValue('doc_123');

      mockAI.executeFlow.mockResolvedValue({ status: 'indexed' });

      // ACT

      const result = await service.ingestContract('Contract text', { type: 'services' });

      // ASSERT

      expect(result.document_id).toBe('doc_123');

      expect(mockRepo.save).toHaveBeenCalledTimes(1);

      expect(mockAI.executeFlow).toHaveBeenCalledWith('legal_ingest', expect.any(Object));

    });

    it('should handle AI provider failure gracefully', async () => {

      // ARRANGE

      mockRepo.save.mockResolvedValue('doc_123');

      mockAI.executeFlow.mockRejectedValue(new Error('AI timeout'));

      // ACT

      const result = await service.ingestContract('Contract text');

      // ASSERT: Document saved despite AI failure

      expect(result.document_id).toBe('doc_123');

      expect(mockLogger.warn).toHaveBeenCalledWith(

        expect.stringContaining('AI indexing failed'),

        expect.any(Object)

      );

    });

  });

});

```

**Принципы тестируемости:**

- ✅ Dependency Injection

- ✅ Interface-based design

- ✅ Pure functions где возможно

- ✅ Изоляция side effects

- ✅ Мокируемые зависимости

---

### 10. **Вертикальная структура по доменам**

Группируйте код по доменам (vertical slices), а не по техническим слоям.

#### ✅ Хорошо (Vertical Slices):

```

api/src/domains/

├── legal/

│   ├── contracts.routes.ts     // HTTP endpoints

│   ├── contracts.service.ts    // Business logic

│   ├── contracts.repository.ts // Data access

│   ├── contracts.types.ts      // Domain types

│   ├── contracts.errors.ts     // Domain errors

│   ├── contracts.flows.ts      // Flow IDs config

│   └── __tests__/

│       └── contracts.service.test.ts

├── infosec/

│   ├── policies.routes.ts

│   ├── policies.service.ts

│   ├── policies.repository.ts

│   └── ...

└── assistant/

    ├── chat.routes.ts

    ├── chat.service.ts

    └── ...

```

**Преимущества:**

- ✅ Все связанное с доменом в одном месте

- ✅ Легко добавить новый домен (просто скопировать структуру)

- ✅ Легко найти нужный код

- ✅ Можно выделить домен в отдельный микросервис

#### ❌ Плохо (Horizontal Layers):

```

api/src/

├── routes/

│   ├── contracts.ts

│   ├── policies.ts

│   └── chat.ts

├── services/

│   ├── ContractService.ts

│   ├── PolicyService.ts

│   └── ChatService.ts

└── repositories/

    ├── ContractRepository.ts

    ├── PolicyRepository.ts

    └── ChatRepository.ts

```

**Проблемы:**

- ❌ Код одного домена размазан по разным директориям

- ❌ Сложнее найти все, что относится к домену

- ❌ Труднее рефакторить

---

## 📋 Checklist для нового кода

Перед добавлением нового кода проверьте:

### Комментарии

- [ ] Есть `INTENT` комментарий в начале файла?

- [ ] Сложная логика объяснена?

- [ ] Использованные паттерны помечены `PATTERN:`?

- [ ] Side effects помечены `SIDE_EFFECTS:`?

### Типы и интерфейсы

- [ ] Все типы документированы?

- [ ] Есть примеры использования в JSDoc?

- [ ] Используется Zod для валидации runtime?

### Архитектура

- [ ] Зависимости инжектятся через конструктор?

- [ ] Внешние сервисы за интерфейсами?

- [ ] Pure logic отделена от effects?

- [ ] Код в правильном домене?

### Обработка ошибок

- [ ] Используются typed domain errors?

- [ ] Errors содержат контекст для debugging?

- [ ] Есть graceful degradation где нужно?

### Логирование

- [ ] Используется structured logging?

- [ ] Логи содержат контекст (operation, user_id, etc.)?

- [ ] Нет PII в логах?

### Тестируемость

- [ ] Можно легко написать unit test?

- [ ] Нет hardcoded dependencies?

- [ ] Pure functions где возможно?

---

## 🤖 Примеры для LLM

### Запрос к LLM: "Добавь новый эндпоинт для удаления договора"

**Хороший результат:**

```typescript

// INTENT: Delete contract endpoint

// RESPONSIBILITIES: Validate permissions, delete from storage, cleanup AI index

// FILE: api/src/domains/legal/contracts.routes.ts

fastify.delete('/:id', {

  // PATTERN: Permission-based authorization

  preHandler: [requireAuth, requirePermission('contracts:delete')],

}, async (request, reply) => {

  const { id } = request.params as { id: string };

  

  // INTENT: Delegate to service layer

  await contractService.deleteContract(id, request.user.userId);

  

  return reply.code(204).send();

});

// INTENT: Business logic для удаления договора

// FILE: api/src/domains/legal/contracts.service.ts

export class ContractService {

  /**

   * INTENT: Delete contract and cleanup all related data

   * 

   * FLOW:

   * 1. Verify contract exists

   * 2. Check user has permission

   * 3. Delete from repository

   * 4. Cleanup AI index (best effort)

   * 5. Audit log

   * 

   * @throws ContractNotFoundError if contract doesn't exist

   * @throws UnauthorizedError if user can't delete this contract

   */

  async deleteContract(documentId: string, userId: string): Promise<void> {

    // INTENT: Verify exists

    const contract = await this.repository.findById(documentId);

    if (!contract) {

      throw new ContractNotFoundError(documentId);

    }

    

    // INTENT: Check ownership/permissions

    if (contract.ownerId !== userId && !this.userHasAdminRole(userId)) {

      throw new UnauthorizedError('Cannot delete contract owned by another user');

    }

    

    // EFFECT: Delete from storage

    await this.repository.delete(documentId);

    

    // EFFECT: Cleanup AI index (best effort - don't fail if this fails)

    try {

      await this.aiProvider.deleteIndex(documentId);

    } catch (error) {

      this.logger.warn('Failed to cleanup AI index', { documentId, error });

    }

    

    // EFFECT: Audit log

    this.auditLogger.log({

      action: 'contract.deleted',

      userId,

      resourceId: documentId,

      timestamp: new Date(),

    });

    

    this.logger.info('Contract deleted', { documentId, userId });

  }

}

```

### Запрос к LLM: "Добавь кеширование для результатов Langflow"

**Хороший результат:**

```typescript

// INTENT: Cached AI provider wrapper

// PATTERN: Decorator pattern для добавления кеширования

// RESPONSIBILITIES: Cache hits/misses, TTL management, cache invalidation

// FILE: api/src/providers/CachedAIProvider.ts

export class CachedAIProvider implements IAIProvider {

  constructor(

    private provider: IAIProvider,

    private cache: ICache,

    private ttl: number = 3600 // 1 hour default

  ) {}

  /**

   * INTENT: Execute flow with caching

   * 

   * FLOW:

   * 1. Generate cache key from flow ID + inputs

   * 2. Check cache

   * 3. If hit: return cached result

   * 4. If miss: call provider, cache result, return

   * 

   * PATTERN: Cache-Aside

   */

  async executeFlow(flowId: string, inputs: Record<string, any>): Promise<any> {

    // INTENT: Stable cache key from inputs

    const cacheKey = this.generateCacheKey(flowId, inputs);

    

    // PATTERN: Cache-Aside - check cache first

    const cached = await this.cache.get(cacheKey);

    if (cached) {

      logger.debug('Cache hit', { flowId, cacheKey });

      return JSON.parse(cached);

    }

    

    logger.debug('Cache miss', { flowId, cacheKey });

    

    // INTENT: Call underlying provider

    const result = await this.provider.executeFlow(flowId, inputs);

    

    // INTENT: Store in cache for future requests

    await this.cache.set(cacheKey, JSON.stringify(result), { ttl: this.ttl });

    

    return result;

  }

  /**

   * INTENT: Generate stable cache key from flow + inputs

   * PURE_FUNCTION: Same inputs always produce same key

   */

  private generateCacheKey(flowId: string, inputs: Record<string, any>): string {

    // INTENT: Sort keys for stable stringification

    const sortedInputs = Object.keys(inputs)

      .sort()

      .reduce((acc, key) => {

        acc[key] = inputs[key];

        return acc;

      }, {} as Record<string, any>);

    

    // PATTERN: Hash for compact keys

    const inputsHash = crypto

      .createHash('sha256')

      .update(JSON.stringify(sortedInputs))

      .digest('hex');

    

    return `ai:${flowId}:${inputsHash}`;

  }

  async healthCheck(): Promise<boolean> {

    return this.provider.healthCheck();

  }

}

```

---

## 📚 Дополнительные ресурсы

### Рекомендуемое чтение

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)

- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

- [Vertical Slice Architecture](https://jimmybogard.com/vertical-slice-architecture/)

### Паттерны в проекте

- Repository Pattern

- Strategy Pattern

- Factory Pattern

- Dependency Injection

- Circuit Breaker

- Retry with Exponential Backoff

- Cache-Aside

- Domain-Driven Design

---

## ✅ Заключение

Следуя этим принципам, вы создаёте код, который:

- ✅ Легко понимается и поддерживается людьми

- ✅ Легко понимается и модифицируется LLM

- ✅ Легко тестируется

- ✅ Легко расширяется

- ✅ Устойчив к ошибкам

- ✅ Готов к production

**Помните**: Код читается гораздо чаще, чем пишется. Инвестируйте время в ясность и документацию!


