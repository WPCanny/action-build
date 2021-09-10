# WPCanny - Action Build

A GitHub Action to build WPCanny plugins using Composer and NPM.

## Managing files in the build

Use a `.distignore` file to exclude files from the build.

## Example

```yaml
name: Build release asset
on:
  release:
    types: [published]
jobs:
  build:
    name: Build release asset
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Build
        id: build
        uses: wpcanny/action-build@v1
      - name: Upload release asset
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ${{ steps.build.outputs.zip-path }}
          asset_name: ${{ github.event.repository.name }}-${{ steps.build.outputs.version }}.zip
          asset_content_type: application/zip
```
