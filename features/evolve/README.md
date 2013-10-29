## Consumer-Driven Contract Recommendations

If you are using Pacto for Consumer-Driven Contracts, we recommend avoiding the advanced features so you'll test with the strictest Contract possible.  We recommend:

- Do not use templating, let Pacto use the json-generator
- Use strict request matching
- Use multiple contracts for the same service to capture attributes that are required in some situations but not others

The host address is intentionally left out of the request specification so that we can validate a contract against any provider.
It also reinforces the fact that a contract defines the expectation of a consumer, and not the implementation of any specific provider.

