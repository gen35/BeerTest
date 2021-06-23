FROM julia:1.6.0-buster

WORKDIR /app
ADD . /app

RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.resolve(); Pkg.instantiate(); using BeerTest; main(;output=false)"

ENTRYPOINT ["julia", "-i", "startup.jl"]