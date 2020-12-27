import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import {environment} from '../../../../environments/environment'
import { PostModel } from '../../../shared/model/post';
@Injectable()
export class HeaderService {

  constructor(private http: HttpClient) { }
  
  search(searchText: string): Observable<PostModel[]> {

    const url = environment.apiUrl + '/post/search';
    let body = JSON.stringify(searchText );
    var params = new HttpParams().set('searchText', body);
    let headerss = new HttpHeaders({ 'Content-Type': 'application/json' });
  
    return this.http.post<PostModel[]>(url, body,{headers:headerss,params:params});
  }

}
