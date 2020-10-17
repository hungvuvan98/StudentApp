import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { AuthService } from './common/services/auth/auth.service';
import { AuthGuardService } from './common/services/auth/auth-guard.service';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { TokenInterceptorService } from './common/services/auth/token-interceptor.service';
import { NotificationService } from './common/notification.service';
import { ReactiveFormsModule } from '@angular/forms';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { NotifierModule } from 'angular-notifier';
import{customNotifierOptions} from './configuration/notifier-config.ts'
import { ErrorInterceptorService } from './common/services/error/error-interceptor.service';
import { NgxPaginationModule } from 'ngx-pagination';
import { MainService } from './common/services/main.service';


@NgModule({
  declarations: [
    AppComponent 
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    //ReactiveFormsModule,
    HttpClientModule,
    NgbModule,
    NotifierModule.withConfig(customNotifierOptions),
    NgxPaginationModule
  ],
  providers: [
    AuthService,
    AuthGuardService,
    {
      provide:HTTP_INTERCEPTORS,
      useClass:TokenInterceptorService,
      multi:true
    },
    {
      provide:HTTP_INTERCEPTORS,
      useClass:ErrorInterceptorService,
      multi:true
    },
    NotificationService,
    MainService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
