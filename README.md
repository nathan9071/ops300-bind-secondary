# ops300-bind-secondary

Dockerfile and config for my bind-secondary image from OPS300 Lab 1.

Jenkins builds it with podman on my registry VM (the build agent) and pushes it to my private registry. Images are tagged with the build number and commit SHA, plus latest.

CVE scan: Trivy scans the image for HIGH and CRITICAL vulnerabilities before it is pushed. I chose to save the results as a build artifact (trivy-report.txt) and let the build continue instead of failing it. The scan found no high/critical vulnerabilities in the Ubuntu packages, but found 4 high in Pebble which is a GO binary included with Ubuntu image.
