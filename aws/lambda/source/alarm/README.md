# Layer (dependencies) building

1. Create env folder and execute env shell

```
python -m venv package
source package/bin/activate
```

2. Zip layer

```
mkdir python
cp -r package/lib python/
zip -r layer.zip python 
```

3. Using terraform to create layer then attach layer to lambda

[Lambda layer](https://docs.aws.amazon.com/lambda/latest/dg/python-layers.html)
