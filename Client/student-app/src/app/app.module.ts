import { BrowserModule, Title } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { GuestModule } from './client/guest/guest.module';
import { StudentModule } from './client/student/student.module';
import { InstructorModule } from './client/instructor/instructor.module';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { AuthService } from './shared/services/auth/auth.service';
import { AuthGuardService } from './shared/services/auth/auth-guard.service';
import { TokenInterceptorService } from './shared/services/auth/token-interceptor.service';
import { ErrorInterceptorService } from './shared/services/error/error-interceptor.service';
import { NotificationService } from './shared/services/Notification/Notification.service';
import { MainService } from './shared/services/main.service';
import { NotifierModule } from 'angular-notifier';
import { customNotifierOptions } from './shared/services/Notification/notification-config';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    AppRoutingModule,
    NgbModule,
    //NgxPaginationModule,
    NotifierModule.withConfig(customNotifierOptions),
    GuestModule,
    StudentModule,
    InstructorModule
  ],
  providers: [
    Title,
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
