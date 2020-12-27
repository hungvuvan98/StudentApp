import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import {retry, catchError} from 'rxjs/operators'
import { NotificationService } from '../Notification/Notification.service';

@Injectable({
  providedIn: 'root'
})
export class ErrorInterceptorService implements HttpInterceptor {

  constructor(private noticeService : NotificationService) { }
  
  intercept(request: HttpRequest<any>,next: HttpHandler): Observable<HttpEvent<any>>{
      
      return next.handle(request).pipe(
          retry(1),
          catchError((err)=>{
              if(err.status==401){
                  this.noticeService.show("error", "401 unauthorize");
              }
              else if(err.status==404){
                  this.noticeService.show("error", `${err.error}`);
              }
              else if(err.status==400){
                  this.noticeService.show("error", `${err.error}`);
              }
               else if(err.status==403){
                  this.noticeService.show("error", "status 403, Not Role");
              }
              else{
                  this.noticeService.show("error", "Failed");
              }
              return throwError(err)
          })
      )
    }
  
  }