import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable()
export class AuthService {

    private loginPath = environment.apiUrl + '/account/login';

    constructor(private http: HttpClient, private route: Router) { }

    login(data): Observable<any> {
     return this.http.post(this.loginPath, data);
    }

    logout(){
      localStorage.clear()
      this.route.navigate([''])
    }

    changPassword(data): Observable<any> {
      const url=environment.apiUrl + '/account/ChangePassword'
      return this.http.post(url, data);
    }
  
    saveToken(token){
      localStorage.setItem('token',token);
    }

    getUserId():Observable<string>{
      const url = environment.apiUrl + '/account/GetUserId';

      return this.http.get<string>(url)
    }

    getToken(){
      return localStorage.getItem('token');
    }

    isAuthenticated(){
      if(this.getToken()){
        return true;
      }
      return false;
    }

}
