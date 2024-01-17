# Private registry Image Remove

It gets the repository tags using and orders them by the `created` attribute. For now it will ignore the tags `latest`, `prod`, `stage`, `dev` and the `levels` of most recent tags. It then deletes the older tags.

PRs are welcome.

# Usage
Add this step to a job to automatically delete older images as part of a job:

```yaml
    - name: Remove old images from Container Registry
      uses: capital-d/docker-registry-remove@0.1
      with:
        repository: image-repository # Private image registry url without https://
        image: repository/image # Image as it appear in /v2/_catalog repositories array
        user: user
        password: password
        levels: 5 # Number of images need to leave in registry, default to 5
```

# Inputs
- `repository` - (**Required**) Private image registry url without https://
- `image` - (**Required**) Image as it appear in /v2/_catalog repositories array
- `user` - (**Required**) 
- `password` - (**Required**)
- `levels` - (Optional) Number of images need to leave in registry, default to `5`