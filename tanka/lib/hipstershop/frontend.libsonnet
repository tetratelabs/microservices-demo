(import "ksonnet-util/kausal.libsonnet") +
{

  local deploy = $.apps.v1.deployment,
  local container = $.core.v1.container,
  local port = $.core.v1.containerPort,
  local service = $.core.v1.service,

  _config+:: {
    frontend: {
      app: "frontend",
      namespace: $._config.namespace, //set a default namespace if not overrided in the main file
      port: 8080,
      portName: "http",
      image: {
        repo: $._config.image.repo,
        name: "frontend",
        tag: $._config.image.tag,
      },
      labels: {app: "frontend"},
      env: {
        SRVURL: ":%s" % $._config.frontend.port,
        PRODUCT_CATALOG_SERVICE_ADDR: $._config.productcatalogservice.URL,
        CURRENCY_SERVICE_ADDR: $._config.currencyservice.URL,
        CART_SERVICE_ADDR: $._config.cartservice.URL,
        RECOMMENDATION_SERVICE_ADDR: $._config.recommendationservice.URL,
        SHIPPING_SERVICE_ADDR: $._config.shippingservice.URL,
        CHECKOUT_SERVICE_ADDR: $._config.checkoutservice.URL,
        AD_SERVICE_ADDR: $._config.adservice.URL,
        // BANNER_COLOR: "red",
        // JAEGER_SERVICE_ADDR: "jaeger-collector:14268",
      },
      readinessProbe: container.mixin.readinessProbe.httpGet.withPath("/healthz")
        + container.mixin.readinessProbe.httpGet.withPort(self.port)
        + container.mixin.readinessProbe.httpGet.withHttpHeaders($.envList({Cookie: "shop_session-id=x-readiness-probe"}),)
        + container.mixin.readinessProbe.withInitialDelaySeconds(10),
      livenessProbe: container.mixin.livenessProbe.httpGet.withPath("/healthz")
        + container.mixin.livenessProbe.httpGet.withPort(self.port)
        + container.mixin.livenessProbe.httpGet.withHttpHeaders($.envList({Cookie: "shop_session-id=x-readiness-probe"}),)
        + container.mixin.livenessProbe.withInitialDelaySeconds(10),
      limits: {},
      requests: {},
      deploymentExtra: deploy.mixin.spec.template.metadata.withAnnotations({"sidecar.istio.io/rewriteAppHTTPProbers": "true"}),
      serviceExtra: {},
    },
  },
}