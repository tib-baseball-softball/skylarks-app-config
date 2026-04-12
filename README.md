# SkylarksAppConfig

💧 Microservice to supply runtime configuration to the Skylarks mobile app, built with the Vapor web framework.

## Basic Commands

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```

## Security Considerations

This project only provides HTTP Basic authentication. That layer is later expected to be provided at the web server level (Authentik server + Traefik request configuration) or via an OAuth connection.

### Vapor Documentation

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)
