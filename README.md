## Requirement

### Contabo

We need to provision contabo instance id to the contabo provider first

To get contabo instance id, use its cli tool from there [cntb](https://github.com/contabo/cntb)

```
./cntb get instances
```

Contabo usage only for affordability reason because it is cheap

### AWS secret arn

Create them manually and put hardcodely in the source code

### Netifly

```
npm install netlify-cli --save-dev
yarn netlify login
```

## Tasks

0. aws setup

1. contabo setup

2. vercel static site setup

## Todo

Organize terraform code based on the functionality, or project, not on infrastructure brand 
