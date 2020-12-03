from django.http import HttpRequest, HttpResponse

# from django.shortcuts import render


def index(_: HttpRequest) -> HttpResponse:
    return HttpResponse("Hello, world. You're at the polls index.")
