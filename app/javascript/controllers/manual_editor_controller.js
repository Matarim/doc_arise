import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "pathsList", "parametersContainer", "requestBodyContainer",
    "responsesContainer", "securityContainer", "preview",
    "contentField", "existingContent", "openapiVersion",
    "editorPanel", "previewPanel", "modeToggle"
  ]

  pathsData = {}
  currentPathKey = null

  connect() {
    this.switchTab("parameters")
    setTimeout(() => this.updatePreview(), 200)
    this.showEditor()
    if (this.hasExistingContentTarget && this.existingContentTarget.value) {
      let openapi = { paths: {} }
      let raw = this.existingContentTarget.value.trim()
      if (raw.startsWith('"') && raw.endsWith('"')) {
        raw = JSON.parse(raw)
      }
      openapi = typeof raw === "string" ? JSON.parse(raw) : raw
      this.loadExistingRevision(openapi)
    }
  }

  // ====================== NEW: EDITOR / PREVIEW TOGGLE ======================
  showEditor() {
    this.editorPanelTarget.classList.remove("hidden")
    this.previewPanelTarget.classList.add("hidden")

    this.modeToggleTargets.forEach(btn => {
      const isEditor = btn.textContent.trim() === "Editor"
      btn.classList.toggle("active", isEditor)
      btn.classList.toggle("bg-zinc-900", isEditor)
      btn.classList.toggle("text-white", isEditor)
      btn.classList.toggle("shadow-sm", isEditor)
    })
  }

  showPreview() {
    this.editorPanelTarget.classList.add("hidden")
    this.previewPanelTarget.classList.remove("hidden")
    this.updatePreview()   // ensure latest full preview renders instantly

    this.modeToggleTargets.forEach(btn => {
      const isPreview = btn.textContent.trim() === "Live Preview"
      btn.classList.toggle("active", isPreview)
      btn.classList.toggle("bg-zinc-900", isPreview)
      btn.classList.toggle("text-white", isPreview)
      btn.classList.toggle("shadow-sm", isPreview)
    })
  }

  // ====================== PATHS ======================
  addPath(event) {
    event.preventDefault()
    const pathItem = document.createElement("div")
    pathItem.className = "px-4 py-3 bg-zinc-800 hover:bg-zinc-700 rounded-2xl cursor-pointer flex items-center gap-3 path-item"
    pathItem.innerHTML = `
      <span class="method-badge bg-emerald-900 text-emerald-300 px-3 py-1 text-xs font-mono">GET</span>
      <span class="path font-mono flex-1">/new/path/here</span>
    `
    pathItem.dataset.action = "click->manual-editor#selectPath"
    this.element.querySelector("#paths-list").appendChild(pathItem)
    this.selectPath({ currentTarget: pathItem })
    this.saveCurrentPathState()
    this.updatePreview()
  }

  selectPath(event) {
    this.saveCurrentPathState()
    this.currentPathKey = `${event.currentTarget.querySelector(".method-badge").textContent} ${event.currentTarget.querySelector(".path").textContent}`
    this.loadPathState(this.currentPathKey)
    document.querySelectorAll(".path-item").forEach(item => item.classList.remove("bg-zinc-700"))
    event.currentTarget.classList.add("bg-zinc-700")

    const pathText = event.currentTarget.querySelector(".path")
    console.log(pathText.textContent)
    if (pathText) document.getElementById("selected-path").innerHTML = `<span dir="ltr">${pathText.textContent}</span>`
    this.updatePreview()
  }

  saveCurrentPathState() {
    if (!this.currentPathKey) return
    this.pathsData[this.currentPathKey] = {
      summary: this.getOperationSummary(),
      description: this.getOperationDescription(),
      operationId: this.getOperationId(),
      tags: this.getTags(),
      deprecated: this.isDeprecated(),
      parameters: this.collectParameters(),
      requestBody: this.collectRequestBody(),
      responses: this.collectResponses()
    }
  }

  getOperationSummary() { return document.getElementById("operation-summary")?.value?.trim() || "" }
  getOperationDescription() { return document.getElementById("operation-description")?.value?.trim() || "" }
  getOperationId() {
    const idField = document.getElementById("operation-id")
    return idField?.value?.trim() || this.generateOperationId()
  }
  generateOperationId() {
    const [method, path] = this.currentPathKey.split(" ")
    return `${method.toLowerCase()}${path.replace(/[^a-zA-Z0-9]/g, "")}`
  }
  getTags() { return (document.getElementById("operation-tags")?.value || "").split(",").map(t => t.trim()).filter(Boolean) }
  isDeprecated() { return document.getElementById("operation-deprecated")?.checked || false }


  // ====================== LOAD / PRE-FILL ======================
  loadPathState(key) {
    const data = this.pathsData[key] || {}
    this.parametersContainerTarget.innerHTML = "";
    this.requestBodyContainerTarget.innerHTML = "";
    this.responsesContainerTarget.innerHTML = "";

    (data.parameters || []).forEach(p => this.addParameterFromData(p))
    if (data.requestBody) this.loadRequestBodyFromData(data.requestBody)
    if (data.responses) this.loadResponsesFromData(data.responses)

    // operation metadata
    document.getElementById("operation-summary").value = data.summary || ""
    document.getElementById("operation-description").value = data.description || ""
    document.getElementById("operation-id").value = data.operationId || ""
    document.getElementById("operation-tags").value = (data.tags || []).join(", ")
    document.getElementById("operation-deprecated").checked = !!data.deprecated
    document.getElementById("spec-version").value = data.specVersion || "1.0.0"
  }

  updatePathName(event) {
    const newName = event.currentTarget.textContent.trim()
    const active = document.querySelector(".path-item.bg-zinc-700 .path")
    if (active) active.textContent = newName
  }

  updateMethod(event) {
    const newMethod = event.target.value
    const activeBadge = document.querySelector(".path-item.bg-zinc-700 .method-badge")
    if (activeBadge) activeBadge.textContent = newMethod
    const headerMethod = document.getElementById("selected-method")
    if (headerMethod) headerMethod.textContent = newMethod
  }

  removePath(event) {
    event.preventDefault()
    const active = document.querySelector(".path-item.bg-zinc-700")
    if (active) {
      const keyToDelete = `${active.querySelector(".method-badge").textContent} ${active.querySelector(".path").textContent}`
      delete this.pathsData[keyToDelete]
      active.remove()

      const remaining = document.querySelector(".path-item")
      if (remaining) {
        this.selectPath({ currentTarget: remaining })
      } else {
        this.currentPathKey = null
      }
      this.updatePreview()
    }
  }

  // ====================== TABS ======================
  // ====================== SUB-TAB SWITCHING (updated) ======================
  switchTab(event) {
    // Defensive preventDefault – works for both real button clicks AND mobile select
    if (event && typeof event.preventDefault === "function") {
      event.preventDefault()
    }

    let tab
    if (typeof event === "string") {
      tab = event
    } else if (event && event.currentTarget && event.currentTarget.dataset) {
      tab = event.currentTarget.dataset.tab
    } else if (event && event.target && event.target.value) {
      tab = event.target.value
    }

    if (!tab) return

    // Hide all tab contents
    this.element.querySelectorAll(".tab-content").forEach(content => {
      content.classList.add("hidden")
    })

    // Show the selected one
    const activeContent = this.element.querySelector(`#${tab}-tab`)
    if (activeContent) {
      activeContent.classList.remove("hidden")
    }

    // Update active button styling on desktop only
    this.element.querySelectorAll(".tab-btn").forEach(btn => {
      if (btn.dataset.tab === tab) {
        btn.classList.add("border-b-2", "border-emerald-500", "text-white")
        btn.classList.remove("text-zinc-400")
      } else {
        btn.classList.remove("border-b-2", "border-emerald-500", "text-white")
        btn.classList.add("text-zinc-400")
      }
    })
  }

  // ====================== MOBILE TAB SELECT (updated) ======================
  switchMobileTab(event) {
    const tab = event.target.value
    this.switchTab(tab)                    // now passes string directly
    // Keep the <select> value in sync
    event.target.value = tab
  }

  // ====================== PARAMETERS ======================
  addParameter(event) {
    event.preventDefault()
    const clone = document.getElementById("parameter-template").content.cloneNode(true)
    this.parametersContainerTarget.appendChild(clone)
    this.updatePreview()
  }

  removeParameter(event) {
    event.target.closest(".parameter-row")?.remove()
    this.updatePreview()
  }

  updateParameterType(event) {
    const row = event.target.closest(".parameter-row")
    if (!row) return

    const type = event.target.value
    const stringGroup = row.querySelector(".string-group")
    const numberGroup = row.querySelector(".number-group")

    if (stringGroup) stringGroup.classList.toggle("hidden", !["string"].includes(type))
    if (numberGroup) numberGroup.classList.toggle("hidden", !["number", "integer"].includes(type))
    this.updatePreview()
  }

  addParameterFromData(param) {
    const clone = document.getElementById("parameter-template").content.cloneNode(true)
    const row = clone.querySelector(".parameter-row")
    row.querySelector('input[name*="\\[name\\]"]').value = param.name || ""
    row.querySelector('select[name*="\\[in_location\\]"]').value = param.in || "query"
    row.querySelector('select[name*="\\[type\\]"]').value = param.schema?.type || "string"
    row.querySelector('input[name*="\\[description\\]"]').value = param.description || ""
    row.querySelector('input[name*="\\[example\\]"]').value = param.example || ""
    row.querySelector('input[name*="\\[required\\]"]').checked = param.required || false
    row.querySelector('input[name*="\\[nullable\\]"]').checked = param.schema?.nullable || false
    row.querySelector('select[name*="\\[format\\]"]').value = param.schema?.format || ""
    row.querySelector('input[name*="\\[min_length\\]"]').value = param.schema?.minLength || ""
    row.querySelector('input[name*="\\[max_length\\]"]').value = param.schema?.maxLength || ""
    row.querySelector('input[name*="\\[pattern\\]"]').value = param.schema?.pattern || ""
    row.querySelector('input[name*="\\[minimum\\]"]').value = param.schema?.minimum || ""
    row.querySelector('input[name*="\\[maximum\\]"]').value = param.schema?.maximum || ""
    row.querySelector('input[name*="\\[default\\]"]').value = param.schema?.default || ""
    // row.querySelector('input[name*="\\[allowEmptyValue\\]"]').checked = param.schema?.allowEmptyValue || false
    this.parametersContainerTarget.appendChild(clone)
  }

  // ====================== PARAMETERS ======================
  collectParameters() {
    const params = []
    this.parametersContainerTarget.querySelectorAll(".parameter-row").forEach(row => {
      const name = row.querySelector('input[name*="\\[name\\]"]')?.value?.trim()
      if (!name) return

      const schema = {}
      const type = row.querySelector('select[name*="\\[type\\]"]')?.value || "string"
      if (type) schema.type = type

      const format = row.querySelector('select[name*="\\[format\\]"]')?.value?.trim()
      if (format) schema.format = format

      const defaultVal = row.querySelector('input[name*="\\[default\\]"]')?.value?.trim()
      if (defaultVal) schema.default = defaultVal

      const minLength = row.querySelector('input[name*="\\[min_length\\]"]')?.value?.trim()
      if (minLength) schema.minLength = parseInt(minLength, 10)

      const maxLength = row.querySelector('input[name*="\\[max_length\\]"]')?.value?.trim()
      if (maxLength) schema.maxLength = parseInt(maxLength, 10)

      const pattern = row.querySelector('input[name*="\\[pattern\\]"]')?.value?.trim()
      if (pattern) schema.pattern = pattern

      const minimum = row.querySelector('input[name*="\\[minimum\\]"]')?.value?.trim()
      if (minimum) schema.minimum = parseFloat(minimum)

      const maximum = row.querySelector('input[name*="\\[maximum\\]"]')?.value?.trim()
      if (maximum) schema.maximum = parseFloat(maximum)

      params.push({
        name:        name,
        in:          row.querySelector('select[name*="\\[in_location\\]"]')?.value || "query",
        required:    row.querySelector('input[name*="\\[required\\]"]')?.checked || false,
        schema:      schema,
        description: row.querySelector('input[name*="\\[description\\]"]')?.value?.trim() || "",
        example:     row.querySelector('input[name*="\\[example\\]"]')?.value?.trim() || undefined
      })
    })
    return params
  }

  // ====================== REQUEST BODY ======================
  addRequestBody(event) {
    event.preventDefault()
    const clone = document.getElementById("request-body-template").content.cloneNode(true)
    this.requestBodyContainerTarget.appendChild(clone)
    this.updatePreview()
  }

  removeRequestBody(event) {
    event.target.closest(".request-body-property-row")?.remove()
    this.updatePreview()
  }

  loadRequestBodyFromData(data) {
    const schema = data?.content?.["application/json"]?.schema || {}
    const properties = schema.properties || {}

    Object.keys(properties).forEach(name => {
      const prop = properties[name]
      const clone = document.getElementById("request-body-template").content.cloneNode(true)
      const row = clone.querySelector(".request-body-property-row")

      // Fill core fields
      row.querySelector('input[name*="\\[name\\]"]').value = name
      row.querySelector('select[name*="\\[type\\]"]').value = prop.type || "string"
      row.querySelector('input[name*="\\[description\\]"]').value = prop.description || ""
      row.querySelector('input[name*="\\[example\\]"]').value = prop.example || ""

      // Checkboxes
      const requiredCheckbox = row.querySelector('input[name*="\\[required\\]"]')
      if (requiredCheckbox) requiredCheckbox.checked = schema.required?.includes(name) || false

      const nullableCheckbox = row.querySelector('input[name*="\\[nullable\\]"]')
      if (nullableCheckbox) nullableCheckbox.checked = prop.nullable || false

      // Format + default
      if (prop.format) row.querySelector('select[name*="\\[format\\]"]').value = prop.format
      if (prop.default !== undefined) row.querySelector('input[name*="\\[default\\]"]').value = prop.default

      // Conditional fields (string vs number)
      const stringGroup = row.querySelector(".string-group")
      const numberGroup = row.querySelector(".number-group")

      if (["string"].includes(prop.type)) {
        stringGroup.classList.remove("hidden")
        if (prop.minLength !== undefined) row.querySelector('input[name*="\\[min_length\\]"]').value = prop.minLength
        if (prop.maxLength !== undefined) row.querySelector('input[name*="\\[max_length\\]"]').value = prop.maxLength
        if (prop.pattern) row.querySelector('input[name*="\\[pattern\\]"]').value = prop.pattern
      } else if (["number", "integer"].includes(prop.type)) {
        numberGroup.classList.remove("hidden")
        if (prop.minimum !== undefined) row.querySelector('input[name*="\\[minimum\\]"]').value = prop.minimum
        if (prop.maximum !== undefined) row.querySelector('input[name*="\\[maximum\\]"]').value = prop.maximum
      }

      this.requestBodyContainerTarget.appendChild(clone)
    })
  }

  collectRequestBody() {
    const properties = {}
    const required = []
    this.requestBodyContainerTarget.querySelectorAll(".request-body-property-row").forEach(row => {
      const name = row.querySelector('input[name*="\\[name\\]"]')?.value?.trim()
      if (!name) return
      const type = row.querySelector('select[name*="\\[type\\]"]')?.value || "string"
      if (row.querySelector('input[type="checkbox"][name*="\\[required\\]"]')?.checked) required.push(name)

      properties[name] = {
        type,
        description: row.querySelector('input[name*="\\[description\\]"]')?.value || "",
        example: row.querySelector('input[name*="\\[example\\]"]')?.value || this.getSampleValueForType(type)
      }
    })

    return {
      content: {
        "application/json": {
          schema: {
            type: "object",
            properties,
            required: required.length ? required : undefined
          }
        }
      }
    }
  }

  // ====================== RESPONSES ======================
  addResponse(event) {
    event.preventDefault()
    const clone = document.getElementById("response-template").content.cloneNode(true)
    this.responsesContainerTarget.appendChild(clone)
    this.updatePreview()
  }

  removeResponse(event) {
    event.target.closest(".response-row")?.remove()
    this.updatePreview()
  }

  addResponseProperty(event) {
    event.preventDefault()
    const responseRow = event.target.closest(".response-row")
    if (!responseRow) return
    const list = responseRow.querySelector(".response-properties-list")
    if (!list) return
    const clone = document.getElementById("response-property-template").content.cloneNode(true)
    list.appendChild(clone)
    this.updatePreview()
  }

  removeResponseProperty(event) {
    event.target.closest(".response-property-row")?.remove()
    this.updatePreview()
  }

  loadResponsesFromData(responses) {
    Object.keys(responses).forEach(status => {
      const resp = responses[status]
      const clone = document.getElementById("response-template").content.cloneNode(true)
      const row = clone.querySelector(".response-row")
      row.querySelector('select[name*="status_code"]').value = status
      row.querySelector('input[name*="\\[description\\]"]').value = resp.description || ""

      const props = resp.content?.["application/json"]?.schema?.properties || {}
      const required = resp.content?.["application/json"]?.schema?.required || []
      Object.keys(props).forEach(name => {
        this.addResponsePropertyFromData(row, name, props[name], required.includes(name))
      })
      this.responsesContainerTarget.appendChild(clone)
    })
  }

  addResponsePropertyFromData(responseRow, name, prop, isRequired) {
    const list = responseRow.querySelector(".response-properties-list")
    if (!list) return
    const clone = document.getElementById("response-property-template").content.cloneNode(true)
    const row = clone.querySelector(".response-property-row")

    row.querySelector('input[name*="\\[name\\]"]').value = name
    row.querySelector('select[name*="\\[type\\]"]').value = prop.type || "string"
    row.querySelector('input[name*="\\[description\\]"]').value = prop.description || ""
    row.querySelector('input[name*="\\[example\\]"]').value = prop.example || ""
    row.querySelector('input[name*="\\[required\\]"]').checked = isRequired
    row.querySelector('input[name*="\\[nullable\\]"]').checked = prop.nullable || false

    // trigger type visibility
    const typeSelect = row.querySelector('select[name*="\\[type\\]"]')
    if (typeSelect) this.updatePropertyType({ target: typeSelect })

    list.appendChild(clone)
  }

  collectResponses() {
    const responses = {}
    document.querySelectorAll(".response-row").forEach(row => {
      const status = row.querySelector('select[name*="status_code"]')?.value || "200"
      const properties = {}
      const required = []

      row.querySelectorAll(".response-property-row").forEach(propRow => {
        const name = propRow.querySelector('input[name*="\\[name\\]"]')?.value?.trim()
        if (!name) return
        const type = propRow.querySelector('select[name*="\\[type\\]"]')?.value || "string"
        if (propRow.querySelector('input[type="checkbox"][name*="\\[required\\]"]')?.checked) required.push(name)

        properties[name] = {
          type,
          example: propRow.querySelector('input[name*="\\[example\\]"]')?.value || this.getSampleValueForType(type)
        }
      })

      responses[status] = {
        description: row.querySelector('input[name*="\\[description\\]"]')?.value || "Successful response",
        content: {
          "application/json": {
            schema: { type: "object", properties, required: required.length ? required : undefined }
          }
        }
      }
    })
    return responses
  }

  // ====================== SECURITY ======================
  addSecurityScheme(event) {
    event.preventDefault()
    const clone = document.getElementById("security-scheme-template").content.cloneNode(true)
    this.securityContainerTarget.appendChild(clone)
    this.updatePreview()
  }

  removeSecurityScheme(event) {
    event.target.closest(".security-scheme-row")?.remove()
    this.updatePreview()
  }

  updateSecurityType(event) {
    const row = event.target.closest(".security-scheme-row")
    if (!row) return

    const type = event.target.value
    row.querySelectorAll(".apiKey-group, .http-group, .oauth2-group").forEach(group => {
      group.classList.add("hidden")
    })

    if (type === "apiKey") row.querySelector(".apiKey-group").classList.remove("hidden")
    if (type === "http") row.querySelector(".http-group").classList.remove("hidden")
    if (type === "oauth2") row.querySelector(".oauth2-group").classList.remove("hidden")
  }

  collectSecuritySchemes() {
    const schemes = {}
    this.securityContainerTarget?.querySelectorAll(".security-scheme-row").forEach(row => {
      const name = row.querySelector('input[name*="\\[name\\]"]')?.value?.trim()
      if (!name) return

      const scheme = this.buildSecurityScheme(row)
      if (scheme) schemes[name] = scheme
    })
    return Object.keys(schemes).length ? schemes : undefined
  }

  // ====================== PROPERTY TYPE ======================
  updatePropertyType(event) {
    const row = event.target.closest(".request-body-property-row") || event.target.closest(".response-property-row")
    if (!row) return

    const type = event.target.value
    const stringGroup = row.querySelector(".string-group")
    const numberGroup = row.querySelector(".number-group")

    if (stringGroup) stringGroup.classList.toggle("hidden", !["string"].includes(type))
    if (numberGroup) numberGroup.classList.toggle("hidden", !["number", "integer"].includes(type))
    this.updatePreview()
  }

  // ====================== LIVE PREVIEW ======================
  updatePreview() {
    // Debounce for smooth performance on mobile/touch devices
    if (this.previewTimeout) clearTimeout(this.previewTimeout)
    this.previewTimeout = setTimeout(() => {
      if (!this.currentPathKey) {
        this.renderEmptyPreview()
        return
      }
      const fullPreview = this.buildFullOperationPreview()
      this.renderFullPreview(fullPreview)
    }, 120)
  }

  buildFullOperationPreview() {
    const [method, path] = this.currentPathKey.split(" ")
    return {
      paths: {
        [path]: {
          [method.toLowerCase()]: {
            summary: this.getOperationSummary(),
            description: this.getOperationDescription(),
            operationId: this.getOperationId(),
            tags: this.getTags(),
            deprecated: this.isDeprecated(),
            parameters: this.collectParameters(),
            ...(this.collectRequestBody() && Object.keys(this.collectRequestBody()).length > 0 && { requestBody: this.collectRequestBody() }),
            responses: this.collectResponses() || {}
          }
        }
      }
    }
  }

  renderFullPreview(data) {
    const pane = this.previewTarget
    if (!pane) return

    const jsonString = JSON.stringify(data, null, 2)
    pane.innerHTML = `
    <div class="bg-zinc-900 md:rounded-3xl p-5 border border-zinc-700 h-full flex flex-col">
      <div class="flex items-center justify-between mb-4 flex-shrink-0">
<!--        <span class="text-xs uppercase tracking-widest font-medium text-emerald-400">Live OpenAPI Preview</span>-->
        <span class="px-3 py-1 text-[14px] font-mono bg-zinc-800 rounded-2xl">${this.currentPathKey}</span>
      </div>
      <pre class="flex-1 text-emerald-200 text-sm leading-relaxed overflow-auto bg-zinc-950 p-4 rounded-2xl border border-zinc-800 whitespace-pre max-h-[calc(100vh-280px)] md:max-h-none">${this.escapeHtml(jsonString)}</pre>
    </div>
  `
  }

  renderEmptyPreview() {
    this.previewTarget.innerHTML = `
    <div class="text-zinc-500 italic flex items-center justify-center h-64 text-center px-8">
      Select or add a path to see full live preview
    </div>
  `
  }

  escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;")
  }

  // ====================== SUBMIT + SERIALIZER ======================
  handleSubmit(event) {
    event.preventDefault()

    this.rebuildPathsFromDOM()

    const openapiDoc = this.serializeToOpenAPI()
    this.contentFieldTarget.value = JSON.stringify(openapiDoc, null, 2)

    this.element.requestSubmit()
  }

  rebuildPathsFromDOM() {
    this.pathsData = {}
    document.querySelectorAll(".path-item").forEach(item => {
      const method = item.querySelector(".method-badge").textContent
      const path = item.querySelector(".path").textContent
      const key = `${method} ${path}`
      this.currentPathKey = key
      this.saveCurrentPathState()
    })
  }

  serializeToOpenAPI() {
    const paths = {}
    Object.keys(this.pathsData).forEach(key => {
      const [method, path] = key.split(" ", 2)
      const data = this.pathsData[key]
      paths[path] = paths[path] || {}
      paths[path][method.toLowerCase()] = {
        summary: data.summary,
        description: data.description,
        operationId: data.operationId,
        tags: data.tags.length ? data.tags : undefined,
        deprecated: data.deprecated || undefined,
        parameters: data.parameters,
        requestBody: data.requestBody,
        responses: data.responses
      }
    })

    const version = document.getElementById("spec-version")?.value?.trim() || "1.0.0"

    return {
      openapi: this.openapiVersionTarget?.value || "3.1.0",
      info: {
        title: this.element.dataset.specName || "API Specification",
        version: version,
        description: this.element.dataset.specDescription || ""
      },
      paths,
      components: { securitySchemes: this.collectSecuritySchemes() }
    }
  }

  buildSecurityScheme(row) {
    const type = row.querySelector('select[name*="\\[type\\]"]')?.value
    if (!type) return null

    const description = row.querySelector('input[name*="\\[description\\]"]')?.value?.trim()
    const scheme = { type, description: description || undefined }

    switch (type) {
      case "apiKey":
        scheme.in = row.querySelector('select[name*="\\[in_location\\]"]')?.value || "header"
        scheme.name = row.querySelector('input[name*="\\[param_name\\]"]')?.value?.trim() || "Authorization"
        break
      case "http":
        const httpScheme = row.querySelector('select[name*="\\[scheme\\]"]')?.value || "bearer"
        scheme.scheme = httpScheme
        if (httpScheme === "bearer") {
          const bearerFormat = row.querySelector('input[name*="\\[bearer_format\\]"]')?.value?.trim()
          if (bearerFormat) scheme.bearerFormat = bearerFormat
        }
        break
      case "oauth2":
        scheme.flows = {
          authorizationCode: {
            authorizationUrl: row.querySelector('input[name*="\\[authorization_url\\]"]')?.value?.trim() || "https://auth.example.com/authorize",
            tokenUrl: row.querySelector('input[name*="\\[token_url\\]"]')?.value?.trim() || "https://auth.example.com/token",
            refreshUrl: row.querySelector('input[name*="\\[refresh_url\\]"]')?.value?.trim() || "https://auth.example.com/refresh",
            scopes: this.parseScopes(row)
          }
        }
        break
      case "openIdConnect":
        scheme.openIdConnectUrl = row.querySelector('input[name*="\\[authorization_url\\]"]')?.value?.trim() ||
            "https://auth.example.com/.well-known/openid-configuration"
        break
    }
    return scheme
  }

  parseScopes(row) {
    const scopesText = row.querySelector('textarea[name*="\\[scopes\\]"]')?.value?.trim()
    if (!scopesText) return { "read": "Read access", "write": "Write access" }
    try {
      return JSON.parse(scopesText)
    } catch (e) {
      return { "read": "Read access", "write": "Write access" }
    }
  }

  // ====================== PRE-FILL ======================
  loadExistingRevision(openapi) {
    this.pathsData = {}
    const list = document.getElementById("paths-list")
    if (list) list.innerHTML = ""

    const paths = openapi.paths || {}

    Object.keys(paths).forEach(path => {
      Object.keys(paths[path]).forEach(method => {
        const upperMethod = method.toUpperCase()
        const key = `${upperMethod} ${path}`
        const op = paths[path][method]

        this.pathsData[key] = {
          summary:      op.summary || "",
          description:  op.description || "",
          operationId:  op.operationId || "",
          tags:         op.tags || [],
          deprecated:   !!op.deprecated,
          parameters:   op.parameters || [],
          requestBody:  op.requestBody || {},
          responses:    op.responses || {}
        }

        this.addPathFromData(path, upperMethod)
      })
    })

    const firstPath = document.querySelector(".path-item")
    if (firstPath) this.selectPath({ currentTarget: firstPath })
  }

  addPathFromData(path, method) {
    const pathItem = document.createElement("div")
    pathItem.className = "px-4 py-3 bg-zinc-700 rounded-2xl cursor-pointer flex items-center gap-3 path-item"
    pathItem.innerHTML = `
      <span class="method-badge bg-emerald-900 text-emerald-300 px-3 py-1 text-xs font-mono">${method}</span>
      <span class="path font-mono flex-1">${path}</span>
    `
    pathItem.dataset.action = "click->manual-editor#selectPath"
    const list = document.getElementById("paths-list")
    if (list) {
      list.appendChild(pathItem)
    }
  }

  loadSecuritySchemes(schemes) {
    Object.keys(schemes).forEach(name => {
      const clone = document.getElementById("security-scheme-template").content.cloneNode(true)
      this.securityContainerTarget.appendChild(clone)
    })
  }
}